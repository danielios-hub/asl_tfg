//
//  ASLPreferences.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 1/4/21.
//

import Foundation
import Vision

class ASLConfiguration {
    
    static let shared = ASLConfiguration()
    
    let defaults = UserDefaults.standard
    
    public var handDetectionMinConfidence: VNConfidence {
        get {
            return defaults.float(forKey: Keys.handDetectionMinConfidence)
        }
        set {
            defaults.set(newValue, forKey: Keys.handDetectionMinConfidence)
        }
    }
    
    public var letterDetectionMinConfidence: VNConfidence {
        get {
            return defaults.float(forKey: Keys.letterDetectionMinConfidence)
        }
        set {
            defaults.set(newValue, forKey: Keys.letterDetectionMinConfidence)
        }
    }
    
    public var minLettersToCompare: Int {
        get {
            return defaults.integer(forKey: Keys.minLettersToCompare)
        }
        set {
            defaults.set(newValue, forKey: Keys.minLettersToCompare)
        }
    }
    
    public var minOcurrences: Int {
        get {
            return defaults.integer(forKey: Keys.minOcurrences)
        }
        set {
            defaults.set(newValue, forKey: Keys.minOcurrences)
        }
    }
    
    public var handCase: HandCase {
        get {
            if let handRaw = defaults.string(forKey: Keys.handCase),
               let handCase = HandCase(rawValue: handRaw) {
                return handCase
            } else {
                return .right
            }
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.handCase)
        }
    }
    
    public var model: ASLModel {
        get {
            if let modelRaw = defaults.string(forKey: Keys.model),
               let modelCase = ASLModel(rawValue: modelRaw) {
                return modelCase
            } else {
                return .shortv3
            }
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.model)
        }
    }
    
    public var isDebugMode: Bool {
        get {
            return defaults.bool(forKey: Keys.debugMode)
        }
        set {
            defaults.set(newValue, forKey: Keys.debugMode)
        }
    }
    
    public var workingMode: WorkingMode {
        get {
            if let value = defaults.string(forKey: Keys.workingMode),
               let mode = WorkingMode(rawValue: value) {
                return mode
            }
            return .free
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.workingMode)
        }
    }
    
    public var isTextCheckerEnabled: Bool {
        get {
            return defaults.bool(forKey: Keys.textChekerEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.textChekerEnabled)
        }
    }
    
    public var isHandFilterByMidX: Bool {
        get {
            return defaults.bool(forKey: Keys.isEnabledHandByMid)
        }
        set {
            defaults.set(newValue, forKey: Keys.isEnabledHandByMid)
        }
    }
    
    public var isSetDefaultValues: Bool {
        get {
            return defaults.bool(forKey: Keys.setDefaultValues)
        }
        set {
            defaults.set(newValue, forKey: Keys.setDefaultValues)
        }
    }
    
    lazy var aslModelv4: ASLHandPointv4? = {
        return try? ASLHandPointv4(configuration: MLModelConfiguration())
    }()
    
    lazy var aslModelv5: ASLHandPointv5? = {
        return try? ASLHandPointv5(configuration: MLModelConfiguration())
    }()
    
    lazy var aslModelShortv1: ASLHandPointv6? = {
        return try? ASLHandPointv6(configuration: MLModelConfiguration())
    }()
    
    lazy var aslModelShortv2: ASLHandPointShortV2? = {
        return try? ASLHandPointShortV2(configuration: MLModelConfiguration())
    }()
    
    lazy var aslModelShortv3: ASLHandPointShortV3? = {
        return try? ASLHandPointShortV3(configuration: MLModelConfiguration())
    }()
    
    enum HandCase: String, CaseIterable {
        case left = "Left"
        case right = "Right"
    }
    
    enum ASLModel: String, CaseIterable {
        case v4 = "v4"
        case v5 = "v5"
        case shortv1 = "Shortv1"
        case shortv2 = "ShortV2"
        case shortv3 = "ShortV3"
    }
    
    enum WorkingMode: String, CaseIterable {
        case free = "Free"
        case letterOcurrencies = "Letter occurrences"
        case words = "Detect words"
    }
    
    private init() {
        if !isSetDefaultValues {
            setDefaultValues()
        }
    }
    func prediction(multiArrayBuffer: MLMultiArray) -> [String : Double] {
        switch model {
        case .v4:
            if let predictions = try? self.aslModelv4?.prediction(handpoint: multiArrayBuffer) {
                return predictions.labelProbability
            }
        case .shortv1:
            if let predictions = try? self.aslModelShortv1?.prediction(handpoint: multiArrayBuffer) {
                return predictions.labelProbability
            }
        case .shortv2:
            if let predictions = try? self.aslModelShortv2?.prediction(handpoint: multiArrayBuffer) {
                return predictions.labelProbability
            }
        case .shortv3:
            if let predictions = try? self.aslModelShortv3?.prediction(handpoint: multiArrayBuffer) {
                return predictions.labelProbability
            }
        default:
            if let predictions = try? self.aslModelv5?.prediction(handpoint: multiArrayBuffer) {
                return predictions.labelProbability
            }
        }
        return [:]
    }
}

public func print(_ objects: Any...) {
    if ASLConfiguration.shared.isDebugMode {
        #if DEBUG
        for object in objects {
            Swift.print(object)
        }
        #endif
    }
}
public func print(_ object: Any) {
    if ASLConfiguration.shared.isDebugMode {
        #if DEBUG
        Swift.print(object)
        #endif
    }
}

//MARK: - UserDefaults

extension ASLConfiguration {
    
    struct Keys {
        static var handDetectionMinConfidence = "handDetectionMinConfidence"
        static var letterDetectionMinConfidence = "letterDetectionMinConfidence"
        static var textChekerEnabled = "textChekerEnabled"
        static var workingMode = "workingMode"
        static var minLettersToCompare = "minLettersToCompare"
        static var minOcurrences = "minOcurrences"
        static var isEnabledHandByMid = "isEnabledHandByMid"
        static var handCase = "handCase"
        static var model = "model"
        static var debugMode = "debugMode"
        static var setDefaultValues = "setDefaultValues"
    }
    
    func setDefaultValues() {
        handDetectionMinConfidence = 0.9
        letterDetectionMinConfidence = 0.5
        isHandFilterByMidX = true
        isTextCheckerEnabled = true
        minLettersToCompare = 4
        minOcurrences = 2
        handCase = HandCase.right
        model = .shortv3
        isDebugMode = true
        isSetDefaultValues = true
    }
}
