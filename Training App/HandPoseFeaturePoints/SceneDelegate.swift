//
//  SceneDelegate.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let navVC = UINavigationController()
        coordinator = MainCoordinator(navigationController: navVC)
        coordinator?.start()
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
}

