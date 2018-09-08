//
//  Debuggable.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/25.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa
import Result
import UIKit

public protocol Debuggable: View where Self: UIResponder {}

extension Debuggable where Self: UIViewController, Self.State: Codable {
    func hookShake(state: Signal<Self.State, NoError>) {
        let debugResponder = DebugDummyResponder(frame: .zero)
        view.addSubview(debugResponder)
        debugResponder.reactive.becomeFirstResponder <~ reactive.viewDidAppear
        debugResponder.motionBegan
            .withLatest(from: state).map { $1 }
            .observeValues { state in
                let encoder = JSONEncoder()
                let data = try! encoder.encode(state)
                print(String(data: data, encoding: .utf8)!)
        }
    }
}

final class DebugDummyResponder: UIView {

    override var canBecomeFirstResponder: Bool { return true }
    let motionBegan: Signal<Void, NoError>
    private let motionBeganInput: Signal<Void, NoError>.Observer

    override init(frame: CGRect) {
        (motionBegan, motionBeganInput) = Signal<Void, NoError>.pipe()
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        motionBeganInput.send(value: ())
    }
}
