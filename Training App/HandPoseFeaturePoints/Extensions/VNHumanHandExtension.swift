//
//  VNHumanHandExtension.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 1/3/21.
//

import Foundation
import Vision

extension VNHumanHandPoseObservation.JointsGroupName {
    var description: String {
        switch self {
        case .indexFinger:
            return "Index"
        case .ringFinger:
            return "Ring"
        case .littleFinger:
            return "Little"
        case .middleFinger:
            return "Middle"
        case .thumb:
            return "Thumb"
        default: return "Unknown"
        }
    }
}
