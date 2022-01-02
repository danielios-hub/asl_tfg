//
//  ExtractFeaturesPicturesViewModel.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import Foundation

public protocol ExtractFeaturesPicturesDelegate: class {
    func update(current: Int, total: Int)
    func didCompressResults(at url: URL?)
}

class ExtractFeaturesPicturesViewModel {
    
    //MARK: - Instance properties
    
    public var dataSource: ApiDataSource
    public var imagesProcessProtocol: ProcessImageProtocol
    
    var shouldLoadImages = false {
        didSet {
            if shouldLoadImages {
                loadImagesFromDataSource()
            }
        }
    }
    
    var urlsImages = [LabelClass: [String]]() {
        didSet {
            loadImagesClosure!()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            loadingIndicatorClosure?()
        }
    }
    
    var hasLatestResults: Bool = false {
        didSet {
            if hasLatestResults {
                enabledLatestResults?()
            }
        }
    }
    
    var loadImagesClosure: (() -> Void)?
    var errorLoadingUrlsClosure: (()  -> Void)?
    var loadingIndicatorClosure: (() -> Void)?
    var updateLoadingImages: ((Int, Int) -> Void)?
    var shareZipClosure: ((URL) -> Void)?
    var enabledLatestResults: (() -> Void)?
    
    public var nextImage: String {
        return urlsImages.first?.value.first ?? ""
    }
    
    //MARK: - Life cicle
    
    init(dataSource: ApiDataSource, processProtocol: ProcessImageProtocol ){
        self.dataSource = dataSource
        self.imagesProcessProtocol = processProtocol
    }
    
    func loadImagesFromDataSource() {
        self.isLoading = true
        dataSource.loadUrlsImages { data in
            self.urlsImages = data
            self.processImages()
        } errorHandler: {
            self.errorLoadingUrlsClosure?()
            self.isLoading = false
        }

    }
    
    func processImages() {
        imagesProcessProtocol.delegate = self
        imagesProcessProtocol.processData(urlsImages)
    }
    
    func checkLatestResults() {
        hasLatestResults = FileWorker.sharedInstance.existsTrainingResults()
    }
    
    func downloadLatestResults() {
        imagesProcessProtocol.delegate = self
        isLoading = true
        DispatchQueue.global().async {
            self.imagesProcessProtocol.compressAndShare()
        }
    }
    
}

extension ExtractFeaturesPicturesViewModel: ExtractFeaturesPicturesDelegate {
    
    func update(current: Int, total: Int) {
        DispatchQueue.main.async {
            self.updateLoadingImages?(current, total)
        }
    }
    
    func didCompressResults(at url: URL?) {
        isLoading = false 
        if let url = url {
            shareZipClosure?(url)
        } else {
            self.errorLoadingUrlsClosure?()
        }
    }
}
