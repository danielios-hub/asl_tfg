//
//  MainCoordinator.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import UIKit

class MainCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ExtractFeaturesPicturesVC.instantiate()
        vc.coordinator = self
        vc.viewModel = ExtractFeaturesPicturesViewModel(dataSource: ApiManager.sharedInstance, processProtocol: VisionProcessImage.sharedInstance)
        navigationController.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showActivityController(with url: URL) {
        let activity = UIActivityViewController(activityItems: ["Save your training results",
                                                                url],
                                                applicationActivities: nil)
        self.navigationController.topViewController?.present(activity, animated: true)
    }
}

extension MainCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        guard let toViewController = navigationController.transitionCoordinator?.viewController(forKey: .to) else {
            return
        }
        
        //check toViewController class to call actions
    }
    
}
