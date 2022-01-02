//
//  OverlayManagerViewController.swift
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

protocol OverlayManagerDisplayLogic: class {
    
}

class OverlayManagerViewController: UIViewController, OverlayManagerDisplayLogic {
    var interactor: OverlayManagerBusinessLogic?
    var router: (NSObjectProtocol & OverlayManagerRoutingLogic & OverlayManagerDataPassing)?
    
    //MARK: - Instance properties
    
    lazy var closeButton : UIButton! = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(symbol: .xmarkCircleFill), for: .normal)
        let pointSize: CGFloat = 50
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: pointSize), forImageIn: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var configButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(symbol: .gear), for: .normal)
        let pointSize: CGFloat = 50
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: pointSize), forImageIn: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(goToConfig(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = OverlayManagerInteractor()
        let presenter = OverlayManagerPresenter()
        let router = OverlayManagerRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.router?.routeToASLInterpreterVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewwillappear")
    }
    
    func setupView() {
        router?.showCameraViewController()
        
        self.view.addSubview(closeButton)
        self.view.addSubview(configButton)
        
        let iconSize: CGFloat = 40
        let margin: CGFloat = 10
        NSLayoutConstraint.activate ( [
            closeButton.widthAnchor.constraint(equalToConstant: iconSize),
            closeButton.heightAnchor.constraint(equalToConstant: iconSize),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: margin),
            
            configButton.widthAnchor.constraint(equalToConstant: iconSize),
            configButton.heightAnchor.constraint(equalToConstant: iconSize),
            configButton.topAnchor.constraint(equalTo: closeButton.topAnchor),
            configButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -margin)
        ])
    }
    
    //MARK: - Actions
    
    @objc func closeAction(_ sender: UIButton) {
        router?.routeToSourcePicker()
    }

    @objc func goToConfig(_ sender: UIButton) {
        router?.routeToConfiguration()
    }
}