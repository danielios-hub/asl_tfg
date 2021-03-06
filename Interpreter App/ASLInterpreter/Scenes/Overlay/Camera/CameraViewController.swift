//
//  CameraViewController.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 28/3/21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import AVFoundation

protocol CameraDisplayLogic: class {
    func pauseVideo()
    func resumeVideo()
}

protocol CameraViewControllerDelegate: class {
    func cameraViewController(_ controller: CameraViewController, didReceiveBuffer buffer: CMSampleBuffer, orientation: CGImagePropertyOrientation)
}

class CameraViewController: UIViewController, CameraDisplayLogic {
    var interactor: CameraBusinessLogic?
    var router: (NSObjectProtocol & CameraRoutingLogic & CameraDataPassing)?
    
    //MARK: - Instance properties
    
    weak var delegate: CameraViewControllerDelegate?
    private let cameraQueue = DispatchQueue(label: "CameraDataOutput",
                                           qos: .userInitiated, attributes: [],
                                           autoreleaseFrequency: .workItem)
    
    // live camera
    private var cameraView: CameraView!
    private var cameraFeedSession: AVCaptureSession?
    
    //video file
    private var videoRenderView: VideoRenderView!
    private var playerItemOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private let videoFileQueue = DispatchQueue(label: "VideoFileOutput", qos: .userInteractive)
    private var videoFileBufferOrientation = CGImagePropertyOrientation.up
    private var videoFileFrameDuration = CMTime.invalid
    private var limitFPS: Double = 10
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = CameraInteractor()
        let presenter = CameraPresenter()
        let router = CameraRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let (videoAsset) = interactor?.recordedVideoSource {
            startReadingAsset(videoAsset)
        } else {
            setupAVSession()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraFeedSession?.stopRunning()
        displayLink?.invalidate()
    }
    
    //MARK: - Utils
    
    func showError(_ msg: String) {
        view.makeToast(msg)
    }
    
    func setupView(_ setupView: UIView) {
        setupView.backgroundColor = .black
        setupView.fillLayout(inView: self.view)
    }
    
    func viewPointForVisionPoint(_ visionPoint: CGPoint) -> CGPoint {
        let flippedPoint = visionPoint.applying(CGAffineTransform.verticalFlip)
        let viewPoint: CGPoint
        if cameraFeedSession != nil {
            viewPoint = cameraView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
        } else {
            viewPoint = videoRenderView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
        }
        return viewPoint
    }
    
    func viewRectForVisionRect(_ visionRect: CGRect) -> CGRect {
        let flippedRect = visionRect.applying(CGAffineTransform.verticalFlip)
        let viewRect: CGRect
        if cameraFeedSession != nil {
            viewRect = cameraView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
        } else {
            viewRect = videoRenderView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
        }
        return viewRect
    }
    
    func pauseVideo() {
        if let _ = interactor?.recordedVideoSource {
            videoRenderView.player?.pause()
        } else {
            cameraFeedSession?.stopRunning()
        }
    }
    
    func resumeVideo() {
        if let (_) = interactor?.recordedVideoSource {
            videoRenderView.player?.play()
        } else {
            cameraFeedSession?.startRunning()
        }
    }
     

}

//MARK: - AVSession

extension CameraViewController {
    
    func setupAVSession() {
        let wideAngle = AVCaptureDevice.DeviceType.builtInWideAngleCamera
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [wideAngle],
                                                                mediaType: .video, position: .unspecified)
        
        guard let videoDevice = discoverySession.devices.first else {
            showError("no device found")
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            showError("error capture input device")
            return
        }
        
        videoDevice.set(frameRate: limitFPS)
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        session.sessionPreset = videoDevice.supportsSessionPreset(.hd1920x1080) ? .hd1920x1080 : .high
        
        guard session.canAddInput(deviceInput) else {
            showError("Error adding input to a session")
            return
        }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            dataOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        } else {
            showError("can not add output")
        }
        
        let captureConnection = dataOutput.connection(with: .video)
        captureConnection?.preferredVideoStabilizationMode = .standard
        captureConnection?.isEnabled = true
        session.commitConfiguration()
        cameraFeedSession = session
        
        let videoOrientation = AVCaptureVideoOrientation.landscapeRight
        cameraView = CameraView(frame: view.bounds,
                                    session: session,
                                    videoOrientation: videoOrientation)
        setupView(cameraView)
        cameraFeedSession?.startRunning()
        
        
    }
}

//MARK: - Reading AVAsset

extension CameraViewController {
    func startReadingAsset(_ asset: AVAsset) {
        videoRenderView = VideoRenderView(frame: view.bounds)
        setupView(videoRenderView)
        
        // Setup display link
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink.preferredFramesPerSecond = Int(limitFPS) // Use display's rate
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.current, forMode: .default)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            showError("no tracks founds")
            return
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        let settings = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: settings)
        playerItem.add(output)
        player.actionAtItemEnd = .pause
        player.play()

        self.displayLink = displayLink
        self.playerItemOutput = output
        self.videoRenderView.player = player

        let affineTransform = track.preferredTransform.inverted()
        let angleInDegrees = atan2(affineTransform.b, affineTransform.a) * CGFloat(180) / CGFloat.pi
        var orientation: UInt32 = 1
        switch angleInDegrees {
        case 0:
            orientation = 1 // Recording button is on the right
        case 180, -180:
            orientation = 3 // abs(180) degree rotation recording button is on the right
        case 90:
            orientation = 8 // 90 degree CW rotation recording button is on the top
        case -90:
            orientation = 6 // 90 degree CCW rotation recording button is on the bottom
        default:
            orientation = 1
        }
        videoFileBufferOrientation = CGImagePropertyOrientation(rawValue: orientation)!
        videoFileFrameDuration = track.minFrameDuration
        displayLink.isPaused = false
    }
    
    @objc
    private func handleDisplayLink(_ displayLink: CADisplayLink) {
        guard let output = playerItemOutput else {
            return
        }
        
        videoFileQueue.async {
            let nextTimeStamp = displayLink.timestamp + displayLink.duration
            let itemTime = output.itemTime(forHostTime: nextTimeStamp)
            guard output.hasNewPixelBuffer(forItemTime: itemTime) else {
                return
            }
            guard let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else {
                return
            }
            // Create sample buffer from pixel buffer
            var sampleBuffer: CMSampleBuffer?
            var formatDescription: CMVideoFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
            let duration = self.videoFileFrameDuration
            var timingInfo = CMSampleTimingInfo(duration: duration, presentationTimeStamp: itemTime, decodeTimeStamp: itemTime)
            CMSampleBufferCreateForImageBuffer(allocator: nil,
                                               imageBuffer: pixelBuffer,
                                               dataReady: true,
                                               makeDataReadyCallback: nil,
                                               refcon: nil,
                                               formatDescription: formatDescription!,
                                               sampleTiming: &timingInfo,
                                               sampleBufferOut: &sampleBuffer)
            if let sampleBuffer = sampleBuffer {
                self.delegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: self.videoFileBufferOrientation)
            }
        }
    }
}

//MARK: - AVCaptureVideo Delegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: .up)
    }
}
