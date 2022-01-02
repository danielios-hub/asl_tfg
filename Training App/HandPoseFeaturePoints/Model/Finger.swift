//
//  Finger.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 18/4/21.
//

import Foundation
import Vision

protocol Finger {
    var name: VNHumanHandPoseObservation.JointsGroupName { get }
    func detectPoint(jointName: VNHumanHandPoseObservation.JointName, point: VNPoint)
    func minMaxPoints() -> (minPoint: CGPoint, maxPoint: CGPoint)
    func normalizeFinger(minX: Double, minY: Double, maxX: Double, maxY: Double)
    func translatesToRelative(minX: Double, minY: Double)
    func extractIfValidFeatures() -> [Double]?
    func printFinger()
}

extension Finger {
    
    func minMaxPoints(from points: [VNPoint?]) -> (minPoint: CGPoint, maxPoint: CGPoint) {
        var currentXMinimum = Double.infinity
        var currentYMinimum = Double.infinity
        
        var currentXMaximum = -Double.infinity
        var currentYMaximum = -Double.infinity
        
        
        points.forEach { point in
            if let point = point {
                currentXMinimum = min(currentXMinimum, point.x)
                currentYMinimum = min(currentYMinimum, point.y)
                
                currentXMaximum = max(currentXMaximum, point.x)
                currentYMaximum = max(currentYMaximum, point.y)
            }
        }
       
        let minPoint = CGPoint(x: currentXMinimum, y: currentYMinimum)
        let maxPoint = CGPoint(x: currentXMaximum, y: currentYMaximum)
        
        return (minPoint, maxPoint)
    }
}

class InfoFinger: Finger {
    var name: VNHumanHandPoseObservation.JointsGroupName
    var tip: VNPoint?
    var dip: VNPoint?
    var pip: VNPoint?
    var mcp: VNPoint?
    
    init(name: VNHumanHandPoseObservation.JointsGroupName) {
        self.name = name
    }
    
    func detectPoint(jointName: VNHumanHandPoseObservation.JointName, point: VNPoint) {
        switch jointName {
        case .indexTip, .ringTip, .littleTip, .middleTip, .thumbTip:
            self.tip = point
        case .indexDIP, .ringDIP, .littleDIP, .middleDIP, .thumbIP:
            self.dip = point
        case .indexPIP, .ringPIP, .littlePIP, .middlePIP, .thumbMP:
            self.pip = point
        case .indexMCP, .ringMCP, .littleMCP, .middleMCP, .thumbCMC:
            self.mcp = point
        default: break
        }
    }
    
    func minMaxPoints() -> (minPoint: CGPoint, maxPoint: CGPoint) {
        return minMaxPoints(from: [tip, dip, pip, mcp])
    }
    
    func normalizeFinger(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        let divideX = maxX - minX
        let divideY = maxY - minY
        
        if let point = tip {
            let x = (point.x - minX) / divideX
            let y = (point.y - minY) / divideY
            self.tip = VNPoint(x: x, y: y)
        }
        
        if let point = dip {
            let x = (point.x - minX) / divideX
            let y = (point.y - minY) / divideY
            self.dip = VNPoint(x: x, y: y)
        }
        
        if let point = pip {
            let x = (point.x - minX) / divideX
            let y = (point.y - minY) / divideY
            self.pip = VNPoint(x: x, y: y)
        }
        
        if let point = mcp {
            let x = (point.x - minX) / divideX
            let y = (point.y - minY) / divideY
            self.mcp = VNPoint(x: x, y: y)
        }
    }
    
    func translatesToRelative(minX: Double, minY: Double) {
        if let point = tip {
            let x = point.x - minX
            let y = point.y - minY
            self.tip = VNPoint(x: x, y: y)
        }
        
        if let point = dip {
            let x = point.x - minX
            let y = point.y - minY
            self.dip = VNPoint(x: x, y: y)
        }
        
        if let point = pip {
            let x = point.x - minX
            let y = point.y - minY
            self.pip = VNPoint(x: x, y: y)
        }
        
        if let point = mcp {
            let x = point.x - minX
            let y = point.y - minY
            self.mcp = VNPoint(x: x, y: y)
        }
    }
    
    func extractIfValidFeatures() -> [Double]? {
        guard let tip = tip, let dip = dip, let pip = pip, let mcp = mcp else {
            return nil
        }
        
        var features: [Double] = []
        
        [tip, dip, pip, mcp].forEach {
            features.append($0.x)
            features.append($0.y)
        }
        
        return features
    }

    func printFinger() {
        print("finger: \(self.name.description)")
        print("tip: \(String(describing: self.tip))")
        print("dip: \(String(describing: self.dip))")
        print("pip: \(String(describing: self.pip))")
        print("cmp: \(String(describing: self.mcp))")
        print()
    }
}

class Wrist: Finger {
    var name: VNHumanHandPoseObservation.JointsGroupName
    var wrist: VNPoint?
    
    init(name: VNHumanHandPoseObservation.JointsGroupName) {
        self.name = name
    }
    
    func detectPoint(jointName: VNHumanHandPoseObservation.JointName, point: VNPoint) {
        switch jointName {
        case .wrist:
            wrist = point
        default: break
        }
    }
    
    func minMaxPoints() -> (minPoint: CGPoint, maxPoint: CGPoint) {
        return minMaxPoints(from: [wrist])
    }
    
    func printFinger() {
        print("finger: \(self.name.description)")
        print("wrist: \(String(describing: self.wrist))")
        print()
    }
    
    func normalizeFinger(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        let divideX = maxX - minX
        let divideY = maxY - minY
        
        if let point = wrist {
            let x = (point.x - minX) / divideX
            let y = (point.y - minY) / divideY
            self.wrist = VNPoint(x: x, y: y)
        }
    }
    
    func translatesToRelative(minX: Double, minY: Double) {
        if let point = wrist {
            let x = point.x - minX
            let y = point.y - minY
            self.wrist = VNPoint(x: x, y: y)
        }
    }
    
    func extractIfValidFeatures() -> [Double]? {
        guard let wrist = wrist else {
            return nil
        }
        
        return [wrist.x, wrist.y]
    }
        
}
