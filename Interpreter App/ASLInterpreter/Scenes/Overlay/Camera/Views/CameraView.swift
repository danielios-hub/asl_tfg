//
//  CameraView.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 28/3/21.
//

import UIKit
import AVFoundation

protocol NormalizedCoordinates {
    func viewRectConverted(fromNormalizedContentsRect normalizedRect: CGRect) -> CGRect
    func viewPointConverted(fromNormalizedContentsPoint normalizedPoint: CGPoint) -> CGPoint
}

class CameraView: UIView, NormalizedCoordinates {
    
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    init(frame: CGRect, session: AVCaptureSession, videoOrientation: AVCaptureVideoOrientation) {
        super.init(frame: frame)
        previewLayer = layer as? AVCaptureVideoPreviewLayer
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspect
        previewLayer.connection?.videoOrientation = videoOrientation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewRectConverted(fromNormalizedContentsRect normalizedRect: CGRect) -> CGRect {
        return previewLayer.layerRectConverted(fromMetadataOutputRect: normalizedRect)
    }
    
    func viewPointConverted(fromNormalizedContentsPoint normalizedPoint: CGPoint) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
    }
    
}

class VideoRenderView: UIView, NormalizedCoordinates {
    
    private var renderLayer: AVPlayerLayer!
    
    var player: AVPlayer? {
        get {
            return renderLayer.player
        }
        set {
            renderLayer.player = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        renderLayer = layer as? AVPlayerLayer
        renderLayer.videoGravity = .resizeAspect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewRectConverted(fromNormalizedContentsRect normalizedRect: CGRect) -> CGRect {
        let videoRect = renderLayer.videoRect
        
        let originX = videoRect.origin.x + (normalizedRect.origin.x * videoRect.width)
        let originY = videoRect.origin.y + (normalizedRect.origin.y * videoRect.height)
        
        let width = normalizedRect.width * videoRect.width
        let height = normalizedRect.height * videoRect.height
        
        let convertedRect = CGRect(x: originX, y: originY, width: width, height: height)
        return convertedRect.integral
    }
    
    func viewPointConverted(fromNormalizedContentsPoint normalizedPoint: CGPoint) -> CGPoint {
        let videoRect = renderLayer.videoRect
        let x = videoRect.origin.x + (normalizedPoint.x * videoRect.width)
        let y = videoRect.origin.y + (normalizedPoint.y * videoRect.height)
        return CGPoint(x: x, y: y)
    }
    
    
}
