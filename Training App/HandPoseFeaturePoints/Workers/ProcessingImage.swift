//
//  ProcessingImage.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import UIKit
import Vision

public protocol ProcessImageProtocol {
    func processData(_ data: [LabelClass: [String]])
    func compressAndShare()
    var delegate: ExtractFeaturesPicturesDelegate? { get set }
}

class VisionProcessImage: ProcessImageProtocol {
    
    static var sharedInstance = VisionProcessImage()
    weak var delegate: ExtractFeaturesPicturesDelegate?
    
    private var handPoseRequest: VNDetectHumanHandPoseRequest
    
    private let processingImageQueue = DispatchQueue(label: "es.danigp.proccessingImage", qos: .userInteractive)
    private let semaphoreProcessing = DispatchSemaphore(value: 1)
    
    private let minConfidenceObservation: Float = 0.3
    
    private var dataHand: [LabelClass: [Hand]] = [:]
    
    var numberOfProcess: Int = 0 {
        didSet {
            print(numberOfProcess)
        }
    }
    
    var totalProcess: Int = 0
    
    private init() {
        handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
    }
    
    func processData(_ data: [LabelClass: [String]]) {
        let group = DispatchGroup()
        
        var totalUrls = 0
        data.values.forEach { urls in
            totalUrls += urls.count
        }
        
        LabelClass.allCases.forEach { labelKey in
            guard let values = data[labelKey] else {
                print("key \(labelKey.rawValue) not found")
                return
            }

            processingImageQueue.async { [unowned self] in
                processClass(labelKey, urls: values, group: group, totalImages: totalUrls)
            }
        }
        
        group.notify(queue: processingImageQueue) { [unowned self] in
            print("all done, process \(self.numberOfProcess) of \(self.totalProcess)")
            saveFeatures()
            compressAndShare()
        }
    }
    
    private func processClass(_ letter: LabelClass, urls: [String], group: DispatchGroup, totalImages: Int) {
        group.enter()
        defer {
            group.leave()
        }
        
        var newHandData = [Hand]()
        for url in urls {
            self.semaphoreProcessing.wait()
            totalProcess += 1
            newHandData.append(contentsOf: self.processImage(with: url))
            self.semaphoreProcessing.signal()
            delegate?.update(current: totalProcess, total: totalImages)
        }
        dataHand[letter] = newHandData
    }
    
    private func processImage(with urlString: String) -> [Hand] {
        print("processing")
        
        guard let url = URL(string: urlString) else {
            print("nil url")
            return []
        }
        
        let handlerOriginal = VNImageRequestHandler(url: url, options: [:])
        //let handlerFlipped = VNImageRequestHandler(url: url, orientation: .upMirrored, options: [:])
        var hands: [Hand] = []
        
        //for  handler in [handlerOriginal, handlerFlipped] {
        for  handler in [handlerOriginal] {
            do {
                try handler.perform([self.handPoseRequest])
                
                guard let observations = handPoseRequest.results, !observations.isEmpty else {
                    print("empty observations")
                    continue
                }

                if let hand = processObservations(observations.first!) {
                    hands.append(hand)
                }
            } catch {
                print("error process image \(error)")
                continue
            }
        }

        return hands
    }
    
    func processObservations(_ observation: VNHumanHandPoseObservation) -> Hand? {
        guard observation.confidence >= minConfidenceObservation else {
            print("observation low confidence")
            return nil
        }
        
        do {
            
            let wrist = try observation.recognizedPoint(.wrist)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            let ringFingerPoints = try observation.recognizedPoints(.ringFinger)
            let thumbFingerPoints = try observation.recognizedPoints(.thumb)
            let littleFingerPoints = try observation.recognizedPoints(.littleFinger)
            let middleFingerPoints = try observation.recognizedPoints(.middleFinger)
            
            let hand = HandFingerPoints(indexFingerPoints: indexFingerPoints,
                                        ringFingerPoints: ringFingerPoints,
                                        littleFingerPoints: littleFingerPoints,
                                        middleFingerPoints: middleFingerPoints,
                                        thumbFingerPoints: thumbFingerPoints,
                                        wristPoint: wrist)
            
            hand.normalizeHand()
            numberOfProcess += 1
            return hand
        } catch {
            print(error)
            return nil
        }
        
    }
    
    func saveFeatures() {
        for (label, listHand) in dataHand {
            var listValidFeatures = [[Double]]()
            
            listHand.forEach { hand in
                if let features = hand.extractIfValidFeatures() {
                    listValidFeatures.append(features)
                }
            }
            
            FileWorker.sharedInstance.saveTrainingData(for: label, data: listValidFeatures, header: HandFingerPoints.getHeaderNames())
        }
    }
    
    func compressAndShare() {
        let zipPath = FileWorker.sharedInstance.compressTrainFolder()
        print("zip path \(String(describing: zipPath))")
        
        DispatchQueue.main.async { [delegate = delegate] in
            delegate?.didCompressResults(at: zipPath)
        }
        
    }
    
}

