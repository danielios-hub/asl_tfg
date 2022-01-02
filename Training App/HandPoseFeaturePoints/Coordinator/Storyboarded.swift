//
//  Storyboarded.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import UIKit

public protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let nameVC = NSStringFromClass(self)
        let className = nameVC.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

