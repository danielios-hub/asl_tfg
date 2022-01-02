//
//  ASLInterpreterInteractor.swift
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

protocol ASLInterpreterBusinessLogic {
    func topPredictionLetter(_ letter: String)
    func finishedWord()
}

protocol ASLInterpreterDataStore {
}

class ASLInterpreterInteractor: ASLInterpreterBusinessLogic, ASLInterpreterDataStore {
    var presenter: ASLInterpreterPresentationLogic?
    lazy var worker : ASLInterpreterWorker? = {
        var interpreter = ASLInterpreterWorker()
        interpreter.delegate = self
        return interpreter
    }()
 
    func topPredictionLetter(_ letter: String) {
        worker?.lastPrediction(letter)
    }
    
    func finishedWord() {
        worker?.finishWord()
    }
}

extension ASLInterpreterInteractor: ASLInterpreterDelegate {
    func aslInterpreter(_ controller: ASLInterpreterWorker, didDetectWord word: String) {
        let response = ASLInterpreter.DetectedWord.Response(letter: word)
        presenter?.presentDetectedWord(response: response)
    }
}
