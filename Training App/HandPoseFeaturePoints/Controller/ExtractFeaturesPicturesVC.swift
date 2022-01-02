//
//  ExtractFeaturesPicturesVC.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import UIKit 

class ExtractFeaturesPicturesVC: UIViewController, Storyboarded {
    
    //MARK: - Instance properties
    
    public weak var coordinator: MainCoordinator?
    public var viewModel: ExtractFeaturesPicturesViewModel!
    
    private var extractFeaturesView: ExtractFeaturesPicturesView! {
        guard isViewLoaded else {
            return nil
        }
        return (view as! ExtractFeaturesPicturesView)
    }
    
    //MARK: - Life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
    }
    
    private func setupView() {
        extractFeaturesView.buttonLoad.addTarget(self, action: #selector(loadImages), for: .touchUpInside)
        extractFeaturesView.buttonDownload.addTarget(self, action: #selector(downloadLastestResults), for: .touchUpInside)
        title = "Load Images"
    }
    
    private func setupViewModel() {
        viewModel.loadImagesClosure = { [weak self] in
            guard let firstImage = self?.viewModel.nextImage else {
                return
            }
            self?.extractFeaturesView.setImage(url: firstImage)
        }
        
        viewModel.loadingIndicatorClosure = { [weak self] in
            let isLoading = self?.viewModel.isLoading ?? false
            if isLoading {
                self?.extractFeaturesView.activityIndicator.startAnimating()
            } else {
                self?.extractFeaturesView.activityIndicator.stopAnimating()
                self?.extractFeaturesView.buttonLoad.isEnabled = true
            }
        }
        
        viewModel.errorLoadingUrlsClosure = { [weak self] in
            self?.viewModel.isLoading = false
            self?.extractFeaturesView.buttonLoad.isEnabled = true
        }
        
        viewModel.updateLoadingImages = { [weak self] current, total in
            self?.extractFeaturesView.setTextInformation(current: current, total: total)
        }
        
        viewModel.shareZipClosure = { [weak self] url in
            self?.coordinator?.showActivityController(with: url)
            self?.extractFeaturesView.setDownloadButton()
        }
        
        viewModel.enabledLatestResults = { [weak self] in
            self?.extractFeaturesView.setDownloadButton()
        }
        
        viewModel.checkLatestResults()
    }
    
    @objc func loadImages() {
        viewModel.isLoading = true
        viewModel.shouldLoadImages = true
        extractFeaturesView.buttonLoad.isEnabled = false
    }
    
    @objc func downloadLastestResults() {
        viewModel.downloadLatestResults()
    }
    
    
}
