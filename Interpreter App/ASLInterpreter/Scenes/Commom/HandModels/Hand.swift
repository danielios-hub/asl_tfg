//
//  HandFingerPoints.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 1/3/21.
//

import Foundation
import Vision

protocol Hand {
    func printHand()
    func normalizeHand()
    func extractIfValidFeatures(flipX: Bool) -> [Double]?
}

class HandFingerPoints: Hand {
    
    //MARK: - Instance properties
    
    var indexInfo: Finger
    var ringInfo: Finger
    var littleInfo: Finger
    var middleInfo: Finger
    var thumbInfo: Finger
    var wrist: Finger
    
    //MARK: - Life cicle
    
    init(indexFingerPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint],
         ringFingerPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint],
         littleFingerPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint],
         middleFingerPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint],
         thumbFingerPoints: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint],
         wristPoint: VNRecognizedPoint) {
        
        indexInfo = InfoFinger(name: .indexFinger)
        ringInfo = InfoFinger(name: .ringFinger)
        littleInfo = InfoFinger(name: .littleFinger)
        middleInfo = InfoFinger(name: .middleFinger)
        thumbInfo = InfoFinger(name: .thumb)
        wrist = Wrist(name: VNHumanHandPoseObservation.JointsGroupName.all)
        
    
        for (jointName, point) in indexFingerPoints {
            indexInfo.detectPoint(jointName: jointName, point: point)
        }
        
        for (jointName, point) in ringFingerPoints {
            ringInfo.detectPoint(jointName: jointName, point: point)
        }
        
        for (jointName, point) in littleFingerPoints {
            littleInfo.detectPoint(jointName: jointName, point: point)
        }
        
        for (jointName, point) in middleFingerPoints {
            middleInfo.detectPoint(jointName: jointName, point: point)
        }
        
        for (jointName, point) in thumbFingerPoints {
            thumbInfo.detectPoint(jointName: jointName, point: point)
        }
        
        wrist.detectPoint(jointName: .wrist, point: wristPoint)
    }
    
    //MARK: - Hand protocol
    
    /// normalize points between 0 and 1
    func normalizeHand() {
        translatesToRelativeCoordinatesHand()
        
        var minimumPoint: CGPoint
        var maximumPoint: CGPoint
        (minimumPoint, maximumPoint) = self.minMaxHandPoint()
        
        let minX = Double(minimumPoint.x)
        let maxX = Double(maximumPoint.x)
        let minY = Double(minimumPoint.y)
        let maxY = Double(maximumPoint.y)
        
        indexInfo.normalizeFinger(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        ringInfo.normalizeFinger(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        littleInfo.normalizeFinger(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        middleInfo.normalizeFinger(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        thumbInfo.normalizeFinger(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        wrist.normalizeFinger(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }
    
    /// locale mimX and minY from all points, the will be the 0 coordinates, substract from all points
    func translatesToRelativeCoordinatesHand() {
        var minimumPoint: CGPoint
        var maximumPoint: CGPoint
        (minimumPoint, maximumPoint) = self.minMaxHandPoint()
        print(minimumPoint)
        print(maximumPoint)
        
        let minX = Double(minimumPoint.x)
        let minY = Double(minimumPoint.y)
        
        indexInfo.translatesToRelative(minX: minX, minY: minY)
        ringInfo.translatesToRelative(minX: minX, minY: minY)
        littleInfo.translatesToRelative(minX: minX, minY: minY)
        middleInfo.translatesToRelative(minX: minX, minY: minY)
        thumbInfo.translatesToRelative(minX: minX, minY: minY)
        wrist.translatesToRelative(minX: minX, minY: minY)
    }
    
    
    /// extract the location ol all position in the hand if there is not null data
    /// - Returns: 42 values array with the relatives coordinates of each position of the hand
    func extractIfValidFeatures(flipX: Bool = false) -> [Double]? {
        guard let featuresIndex = indexInfo.extractIfValidFeatures(flipX: flipX),
              let featuresRing = ringInfo.extractIfValidFeatures(flipX: flipX),
              let featuresLittle = littleInfo.extractIfValidFeatures(flipX: flipX),
              let middleInfo = middleInfo.extractIfValidFeatures(flipX: flipX),
              let thumbInfo = thumbInfo.extractIfValidFeatures(flipX: flipX),
              let wristInfo = wrist.extractIfValidFeatures(flipX: flipX) else {
            print("No valid hand")
            return nil
        }
        
        var result = [Double]()
        result.append(contentsOf: featuresIndex)
        result.append(contentsOf: featuresRing)
        result.append(contentsOf: featuresLittle)
        result.append(contentsOf: middleInfo)
        result.append(contentsOf: thumbInfo)
        result.append(contentsOf: wristInfo)
            
        return result
    }
    
    func printHand() {
        print("Hand Data: ")
        [indexInfo, ringInfo, littleInfo, middleInfo, thumbInfo, wrist].forEach {
            $0.printFinger()
        }
    }
    
    
    /// Analize the maximun X and Y coordinates of the hand
    /// - Returns: Two CGPoint contain ( minX, minY),  (maxX, maxY)
    func minMaxHandPoint() -> (minPoint: CGPoint, maxPoint: CGPoint) {
        var currentXMinimum = CGFloat.infinity
        var currentYMinimum = CGFloat.infinity
        
        var currentXMaximum = -CGFloat.infinity
        var currentYMaximum = -CGFloat.infinity
        for finger in [indexInfo, ringInfo, littleInfo, middleInfo, thumbInfo, wrist] {
            var minimum: CGPoint
            var maximum: CGPoint
            (minimum, maximum) = finger.minMaxPoints()
            
            currentXMinimum = min(currentXMinimum, minimum.x)
            currentYMinimum = min(currentYMinimum, minimum.y)
            
            currentXMaximum = max(currentXMaximum, maximum.x)
            currentYMaximum = max(currentYMaximum, maximum.y)
        }
        
        let minPoint = CGPoint(x: currentXMinimum, y: currentYMinimum)
        let maxPoint = CGPoint(x: currentXMaximum, y: currentYMaximum)
        
        return (minPoint, maxPoint)
    }
    
    //MARK: - static methods
    
    static func getHeaderNames() -> String {
        var stringHeader = ""
        for finger in ["Index", "Ring", "Little", "Middle", "Thumb"] {
            for position in ["max", "max_2", "min_2", "min"] {
                for coordinate in ["X", "Y"] {
                    let newColumn = "\(finger)\(position)\(coordinate)"
                    stringHeader += newColumn + ","
                }
            }
        }
        
        stringHeader += "WristX, WristY"
        return stringHeader
    }
    
}


