//
//  StringExtension.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 2/3/21.
//

import Foundation

public extension String {
    func removeArraySeparator() -> String {
        self.replacingOccurrences(of: "[", with: "", options: .literal)
            .replacingOccurrences(of: "]", with: "", options: .literal)
    }
}
