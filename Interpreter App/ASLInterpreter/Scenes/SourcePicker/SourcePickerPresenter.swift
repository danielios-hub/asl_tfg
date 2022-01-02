//
//  SourcePickerPresenter.swift
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

protocol SourcePickerPresentationLogic {
    func presentSources(response: SourcePicker.LoadSources.Response)
}

class SourcePickerPresenter: SourcePickerPresentationLogic {
    weak var viewController: SourcePickerDisplayLogic?
    
    func presentSources(response: SourcePicker.LoadSources.Response) {
        let viewModel = SourcePicker.LoadSources.ViewModel(sources: response.sources)
        viewController?.displaySources(viewModel: viewModel)
    }
}