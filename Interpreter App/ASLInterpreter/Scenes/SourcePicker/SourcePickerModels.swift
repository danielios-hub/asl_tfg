//
//  SourcePickerModels.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 27/3/21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum SourcePicker {
    // MARK: Use cases
    
    enum LoadSources {
        struct Request {
        }
        struct Response {
            let sources: [Source]
        }
        struct ViewModel {
            let sources: [Source]
        }
    }
}

struct Source {
    let type: SourceType
    let image: UIImage?
    let title: String
}

enum SourceType: Int, CaseIterable {
    case realTime = 0
    case library = 1
    case iCloud = 2
    
}
