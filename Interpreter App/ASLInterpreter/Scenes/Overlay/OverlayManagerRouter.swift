//
//  OverlayManagerRouter.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 28/3/21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol OverlayManagerRoutingLogic {
    func routeToASLInterpreterVC()
    func showCameraViewController()
    func routeToSourcePicker()
    func routeToConfiguration()
}

protocol OverlayManagerDataPassing {
    var dataStore: OverlayManagerDataStore? { get }
}

class OverlayManagerRouter: NSObject, OverlayManagerRoutingLogic, OverlayManagerDataPassing {
    weak var viewController: OverlayManagerViewController?
    var dataStore: OverlayManagerDataStore?
    
    // MARK: Routing
    
    func showCameraViewController() {
        guard let viewController = viewController, let view = viewController.view else {
            return
        }
        
        let cameraViewController = CameraViewController()
        var destinationDS = cameraViewController.router?.dataStore
        destinationDS?.recordedVideoSource = dataStore!.videoAsset
        
        cameraViewController.view.frame = view.bounds
        viewController.addChild(cameraViewController)
        cameraViewController.beginAppearanceTransition(true, animated: true)
        view.addSubview(cameraViewController.view)
        cameraViewController.endAppearanceTransition()
        cameraViewController.didMove(toParent: viewController)
        
        
        dataStore?.cameraViewController = cameraViewController
        dataStore?.overlayParentView = UIView(frame: view.bounds)
        dataStore?.overlayParentView.fillLayout(inView: view)
        dataStore?.overlayParentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func routeToASLInterpreterVC() {
        let controllerToPresent = ASLInterpreterViewController()
        presentOverlayViewController(controllerToPresent) { [weak self] in
            if let cameraVC = self?.dataStore?.cameraViewController {
                let viewRect = cameraVC.view.frame
                let videoRect = cameraVC.viewRectForVisionRect(CGRect(x: 0, y: 0, width: 1, height: 1))
                let insets = controllerToPresent.view.safeAreaInsets
                let additionalInsets = UIEdgeInsets(
                        top: videoRect.minY - viewRect.minY - insets.top,
                        left: videoRect.minX - viewRect.minX - insets.left,
                        bottom: viewRect.maxY - videoRect.maxY - insets.bottom,
                        right: viewRect.maxX - videoRect.maxX - insets.right)
                controllerToPresent.additionalSafeAreaInsets = additionalInsets
            }
            
            self?.dataStore?.cameraViewController.delegate = controllerToPresent
        }
    }
    
    public func presentOverlayViewController(_ newOverlayViewController: UIViewController?, completion: (() -> Void)?) {
        defer {
            completion?()
        }
        
        let overlayViewController = dataStore?.overlayViewController
        
        guard overlayViewController != newOverlayViewController,
              let overlayParentView = dataStore?.overlayParentView else {
            return
        }
        
        if let currentOverlay = overlayViewController {
            currentOverlay.willMove(toParent: nil)
            currentOverlay.beginAppearanceTransition(false, animated: true)
            currentOverlay.view.removeFromSuperview()
            currentOverlay.endAppearanceTransition()
            currentOverlay.removeFromParent()
        }
        
        if let newOverlay = newOverlayViewController {
            newOverlay.view.frame = overlayParentView.bounds
            viewController?.addChild(newOverlay)
            newOverlay.beginAppearanceTransition(true, animated: true)
            overlayParentView.addSubview(newOverlay.view)
            newOverlay.endAppearanceTransition()
            newOverlay.didMove(toParent: viewController)
        }
        
        dataStore?.overlayViewController = newOverlayViewController
    }
    
    func routeToSourcePicker() {
        self.viewController?.navigationController?.popViewController(animated: true)
        dataStore?.videoAsset = nil
    }
    
    func routeToConfiguration() {
        dataStore?.isPaused = true
        let configurationVC = ConfigurationViewController()
        
        var destinationDS = configurationVC.router?.dataStore!
        destinationDS?.completionBlock = { [weak self] in
            self?.dataStore?.isPaused = false
        }
        let nav = UINavigationController(rootViewController: configurationVC)
        self.viewController?.present(nav, animated: true, completion: nil)
    }
}
