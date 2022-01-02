//
//  ProcessPinch.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 26/4/21.
//

import UIKit

protocol GestureDataSource {
    func newPoints(thumbTip: CGPoint, indexTip: CGPoint)
    func getCurrentState() -> State
    var didChangeStateClosure: ((State) -> Void)? { get set }
}

enum State {
    case possiblePinch
    case pinched
    case possibleApart
    case apart
    case unknown
}

class HandGestureProcessor: GestureDataSource {
    
    private var state = State.unknown {
        didSet {
            print("\(state)")
            didChangeStateClosure?(state)
        }
    }
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0
    private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    
    var didChangeStateClosure: ((State) -> Void)?
    var lastEventDate: Date?
    var timer: Timer?
    
    init(pinchMaxDistance: CGFloat = 30, evidenceCounterStateTrigger: Int = 3) {
        self.pinchMaxDistance = pinchMaxDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkResetState), userInfo: nil, repeats: true)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }

    func newPoints(thumbTip: CGPoint, indexTip: CGPoint) {
        lastEventDate = Date()
        let distance = indexTip.distance(from: thumbTip)
        if distance < pinchMaxDistance {
            pinchEvidenceCounter += 1
            apartEvidenceCounter = 0
            state = (pinchEvidenceCounter >= evidenceCounterStateTrigger) ? .pinched : .possiblePinch
        } else {
            apartEvidenceCounter += 1
            pinchEvidenceCounter = 0
            state = (apartEvidenceCounter >= evidenceCounterStateTrigger) ? .apart : .possibleApart
        }
    }
    
    func getCurrentState() -> State {
        return state
    }
    
    @objc private func checkResetState() {
        guard let lastEventDate = lastEventDate, state != .unknown else {
            return
        }
        
        let seconds = Date().timeIntervalSince(lastEventDate)
        
        if seconds > 2.0 {
            print("reseting state")
            state = .unknown
        }
    }
}
