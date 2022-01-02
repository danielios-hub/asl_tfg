//
//  ApiManager.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 1/3/21.
//

import Foundation
import Alamofire
import SwiftyJSON

public typealias LoadImagesResult = ([LabelClass: [String]]) -> Void

public protocol ApiDataSource {
    func loadUrlsImages(_ successHandler: @escaping LoadImagesResult, errorHandler: (() -> Void)?)
}

public class ApiManager: ApiDataSource {
    
    public typealias LoadImagesResult = ([LabelClass: [String]]) -> Void
    
    struct EndPoints {
        static var defaultScheme: String = "http://192.168.1.5:8000/"
        static let requestUrlsImages: String = defaultScheme + "api/1.0/training-images"
    }
    
    static var sharedInstance = ApiManager()
    
    private init() { }
    
    public func loadUrlsImages(_ successHandler: @escaping LoadImagesResult, errorHandler: (() -> Void)? = nil) {
        AF.request(EndPoints.requestUrlsImages).responseJSON { response in
            var urlsImages = [LabelClass: [String]]()
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let dicctionary = json.dictionary
                if let keys = dicctionary?.keys {
                    
                    keys.forEach { key in
                        if let classLetter = LabelClass(rawValue: key),
                           let values = dicctionary?[key] {
                            let urls = values.arrayObject as? [String]
                            urlsImages[classLetter] = urls
                        }
                    }
                }
            case .failure(let error):
                debugPrint(error)
                errorHandler?()
            }
            successHandler(urlsImages)
        }
    }
}
