//
//  SceneDelegate.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 27/3/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        goToSourcePicker()
    }
    
    func goToSourcePicker() {
        let sourceVC = SourcePickerViewController()
        let navVC = UINavigationController(rootViewController: sourceVC)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
}

