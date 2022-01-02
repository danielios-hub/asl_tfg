//
//  AppDelegate.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 27/3/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        VisionUtils.warmUpVision()
        return true
    }
    
    
}

