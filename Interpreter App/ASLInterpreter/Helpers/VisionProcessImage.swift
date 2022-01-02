//
//  VisionProcessImage.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 28/3/21.
//

import UIKit
import Vision

public protocol ProcessImageProtocol {
    func processData(_ data: [LabelClass: [String]])
}

class VisionProcessImage: ProcessImageProtocol {
    
    static var sharedInstance = VisionProcessImage()
    
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
        
        LabelClass.allCases.forEach { labelKey in
            guard let values = data[labelKey] else {
                print("key \(labelKey.rawValue) not found")
                return
            }
            
            processingImageQueue.async { [unowned self] in
                processClass(labelKey, urls: values, group: group)
            }
        }
        
        group.notify(queue: processingImageQueue) { [unowned self] in
            print("all done, process \(self.numberOfProcess) of \(self.totalProcess)")
        }
    }
    
    private func processClass(_ letter: LabelClass, urls: [String], group: DispatchGroup) {
        group.enter()
        defer {
            group.leave()
        }
        
        var newHandData = [Hand]()
        for url in urls {
            self.semaphoreProcessing.wait()
            totalProcess += 1
            if let hand = self.processImage(with: url) {
                newHandData.append(hand)
            }
            self.semaphoreProcessing.signal()
        }
        dataHand[letter] = newHandData
    }
    
    private func processImage(with urlString: String) -> Hand? {
        print("processing")
        
        guard let url = URL(string: urlString) else {
            print("nil url")
            return nil
        }

        let handler = VNImageRequestHandler(url: url, options: [:])

        do {
            try handler.perform([self.handPoseRequest])
            
            guard let observations = handPoseRequest.results, !observations.isEmpty else {
                print("empty observations")
                return nil
            }

            return processObservations(observations.first!)
        } catch {
            print("error process image \(error)")
            return nil
        }
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
}


