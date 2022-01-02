//
//  VisionUtils.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 28/3/21.
//

import UIKit
import Vision

struct VisionUtils {
    
    //bounding box
    static func handBoundingBox(for observation: VNHumanHandPoseObservation, minConfidence: Float = 0.1) -> CGRect {
        //vision coordinates start from bottom left.
        
        // Process body points only if the confidence is high.
        guard observation.confidence > minConfidence, let points = try? observation.recognizedPoints(forGroupKey: .all) else {
            return CGRect.zero
        }
        
        // Only use point if hand pose joint was detected reliably.
        var minX: Double = 1
        var minY: Double = 1
        var maxX: Double = 0
        var maxY: Double = 0
        
        for (_, point) in points where point.confidence > minConfidence {
            let pointX = point.x
            let pointY = point.y
            
            if pointX < minX {
                minX = pointX
            }
            
            if pointX > maxX {
                maxX = pointX
            }
            
            if pointY < minY {
                minY = pointY
            }
            
            if pointY > maxY {
                maxY = pointY
            }
        }
        
        let originX = minX
        let originY = minY
        let width = maxX - minX
        let height = maxY - minY
        
        var visionRect = CGRect(x: originX, y: originY, width: width, height: height)
        
        //Add insets half of width, heigt
        let insetWidthMultiplier = 0.5
        let insetHeightMultiplier = 0.5
        
        let insetX = (width * insetWidthMultiplier) / 2
        let insetY = (height * insetHeightMultiplier) / 2
        
        visionRect.origin.x -= CGFloat(insetX)
        visionRect.size.width += CGFloat(insetX * 2)
        
        visionRect.origin.y -= CGFloat(insetY)
        visionRect.size.height += CGFloat(insetY * 2)
        
        return visionRect
    }
    
    /// Filter by left or right hand
    /// - Parameter observations: VNHumanHandPoseObservation
    /// - Returns: left or right hand observation depend on app configuration
    static func filterCaseHand(_ observations: [VNHumanHandPoseObservation]) -> VNHumanHandPoseObservation? {
        return filterObservation(by: ASLConfiguration.shared.handCase, filterByMidXScreen: ASLConfiguration.shared.isHandFilterByMidX, observations: observations)
    }
    
    static func filterBothHands(_ observations: [VNHumanHandPoseObservation]) -> (right: VNHumanHandPoseObservation, left: VNHumanHandPoseObservation?) {
        guard observations.count == 2 else {
            return (right: observations.first!, left: nil)
        }
        
        let firstObservation = observations.first!
        let secondObservation = observations[1]
        
        let firstRect = VisionUtils.handBoundingBox(for: firstObservation)
        let secondRect = VisionUtils.handBoundingBox(for: secondObservation)
        
        if firstRect.minX < secondRect.minX {
            return (firstObservation, secondObservation)
        } else {
            return (secondObservation, firstObservation)
        }
    }
    
    static func filterObservation(by handCase: ASLConfiguration.HandCase, filterByMidXScreen: Bool = false, observations: [VNHumanHandPoseObservation]) -> VNHumanHandPoseObservation? {
        var observation: VNHumanHandPoseObservation = observations.first!
        var visionRect = VisionUtils.handBoundingBox(for: observation)
        let handCase = ASLConfiguration.shared.handCase
        
        for i in (1..<observations.count) {
            let newObservation = observations[i]
            let newVisionRect = VisionUtils.handBoundingBox(for: newObservation)
            
            switch handCase {
            case .right:
                if newVisionRect.origin.x < visionRect.origin.x {
                    observation = newObservation
                    visionRect = newVisionRect
                }
            case .left:
                if (newVisionRect.origin.x + newVisionRect.width) > (visionRect.origin.x + visionRect.width) {
                    observation = newObservation
                    visionRect = newVisionRect
                }
            }
        }
        
        if filterByMidXScreen {
            return VisionUtils.filterHandByCenterPosition(observation: observation, visionRect: visionRect)
        } else {
            return observation
        }
    }
    
    /// filter left or right hand by center of the screen
    /// - Parameters:
    ///   - observation: VNHumanHandPoseObservation
    ///   - visionRect: Rect of the observation in vision coordinates
    /// - Returns: is left hand, only return observation if exists in left part of the screen
    static func filterHandByCenterPosition(observation: VNHumanHandPoseObservation, visionRect: CGRect) -> VNHumanHandPoseObservation? {
        let handCase = ASLConfiguration.shared.handCase
        switch handCase {
        case .right:
            let minX = visionRect.origin.x
            if minX > 0.5 {
                return nil
            }
        case .left:
            let minX = visionRect.origin.x + visionRect.width
            
            if minX < 0.5 {
                return nil
            }
            
        }
        return observation
    }
    
    static func imageRectForVisionRect(_ visionRect: CGRect, originalWidth: CGFloat, originalHeight: CGFloat) -> CGRect {
        let flippedRect = visionRect.applying(CGAffineTransform.verticalFlip)
        let size = max(originalWidth, originalHeight)
        return VNImageRectForNormalizedRect(flippedRect, Int(size), Int(size))
    }
    
    static func warmUpVision() {
        guard let image = UIImage(symbol: .aCircle)?.cgImage else {
            return
        }
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([handPoseRequest])
        let features: [Double] = Array(repeating: 1, count: 42)
        if let multiArrayBuffer = try? MLMultiArray(features) {
            _ = try? ASLConfiguration.shared.prediction(multiArrayBuffer: multiArrayBuffer)
        }
    }
}

