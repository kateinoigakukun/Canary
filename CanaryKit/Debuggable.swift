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

public protocol Debuggable: View where Self: UIResponder, State: Codable {
}

extension Debuggable where Self: UIViewController {
    func hookShake(state: Signal<Self.State, NoError>) {
        let debugResponder = DebugResponder(frame: .zero)
        view.addSubview(debugResponder)
        debugResponder.reactive.becomeFirstResponder <~ reactive.viewDidAppear
        debugResponder.motionBegan
            .withLatest(from: state).map { $1 }
            .observeValues { [unowned self] state in
                let encoder = JSONEncoder()
                let data = try! encoder.encode(state)
                print(String(data: data, encoding: .utf8))
                let vc = UIViewController()
                vc.view.backgroundColor = .red
                let nav = UINavigationController(rootViewController: vc)
                let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
                let closeAction = ReactiveSwift.Action<Void, Void, NoError>(execute: { (_) -> SignalProducer<Void, NoError> in
                    nav.dismiss(animated: true)
                    return SignalProducer.empty
                })
                closeButton.reactive.pressed = CocoaAction(closeAction)
                self.present(nav, animated: true) {
                    vc.navigationItem.leftBarButtonItem = closeButton
                }
//                let dumper = StateDumper()
//                try! state.encode(to: dumper)
//                dumper.storage.container.forEach { self.dump(value: $0) }
        }
    }

    func dump(value: StateDumperStorage.Value, depth: Int = 2) {
        switch value {
        case .keyValue(let key, let value):
            print(String(repeating: "-", count: depth), key)
            self.dump(value: value, depth: depth + 2)
        case .array(let values):
            values.forEach { value in
                self.dump(value: value, depth: depth + 2)
            }
        default:
            print(String(repeating: "-", count: depth), value)
        }
    }
}

final class DebugResponder: UIView {

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

final class DebugDashboardViewController<S: Store>: UIViewController {}

extension DebugDashboardViewController: View {

    typealias Action = S.Action
    typealias State = S.State

    func bind(state: Signal<S.State, NoError>) -> Binder<S.Action> {
        fatalError()
    }
}

class StateDumper: Encoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]
    let storage = StateDumperStorage()

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        return KeyedEncodingContainer(StateKeyedDecodingContainer<Key>(dumper: self, storage: storage))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return StateUnkeyedEncodingContainer(storage: storage)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

extension StateDumper: SingleValueEncodingContainer {
    func encodeNil() throws {
    }

    func encode(_ value: Bool) throws {
        storage.push(.bool(value))
    }

    func encode(_ value: String) throws {
        storage.push(.string(value))
    }

    func encode(_ value: Double) throws {
        fatalError()
    }

    func encode(_ value: Float) throws {
        fatalError()
    }

    func encode(_ value: Int) throws {
        storage.push(.int(value))
    }

    func encode(_ value: Int8) throws {
        fatalError()
    }

    func encode(_ value: Int16) throws {
        fatalError()
    }

    func encode(_ value: Int32) throws {
        fatalError()
    }

    func encode(_ value: Int64) throws {
        fatalError()
    }

    func encode(_ value: UInt) throws {
        fatalError()
    }

    func encode(_ value: UInt8) throws {
        fatalError()
    }

    func encode(_ value: UInt16) throws {
        fatalError()
    }

    func encode(_ value: UInt32) throws {
        fatalError()
    }

    func encode(_ value: UInt64) throws {
        fatalError()
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let dumper = StateDumper()
        try value.encode(to: dumper)
        storage.push(.array(dumper.storage.container))
    }
}

class StateDumperStorage {
    indirect enum Value {
        case string(String)
        case int(Int)
        case bool(Bool)
        case `nil`
        case array([Value])
        case keyValue(String, Value)
    }

    var container: [Value] = []

    func push<Key: CodingKey>(_ value: Value, for key: Key) {
        container.append(.keyValue(key.stringValue, value))
    }

    func push(_ value: Value) {
        container.append(value)
    }
}

struct StateKeyedDecodingContainer<K: CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    var codingPath: [CodingKey]

    let storage: StateDumperStorage
    let dumper: StateDumper

    init(dumper: StateDumper, storage: StateDumperStorage) {
        self.storage = storage
        self.dumper = dumper
        self.codingPath = []
    }

    private func unimplemented() -> Never {
        fatalError()
    }

    mutating func encodeNil(forKey key: K) throws {
        storage.push(.nil, for: key)
    }

    mutating func encode(_ value: Bool, forKey key: K) throws {
        storage.push(.bool(value), for: key)
    }

    mutating func encode(_ value: String, forKey key: K) throws {
        storage.push(.string(value), for: key)
    }

    mutating func encode(_ value: Double, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: Float, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: Int, forKey key: K) throws {
        storage.push(.int(value), for: key)
    }

    mutating func encode(_ value: Int8, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: Int16, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: Int32, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: Int64, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: UInt, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: UInt8, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: UInt16, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: UInt32, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode(_ value: UInt64, forKey key: K) throws {
        unimplemented()
    }

    mutating func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        let dumper = StateDumper()
        try value.encode(to: dumper)
        storage.push(.array(dumper.storage.container), for: key)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let dumper = StateDumper()
        return dumper.container(keyedBy: NestedKey.self)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        unimplemented()
    }

    mutating func superEncoder() -> Encoder {
        unimplemented()
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        unimplemented()
    }
}

struct StateUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    mutating func encode(_ value: String) throws {
        storage.push(.string(value))
    }

    mutating func encode(_ value: Double) throws {
        fatalError()
    }

    mutating func encode(_ value: Float) throws {
        fatalError()
    }

    mutating func encode(_ value: Int) throws {
        storage.push(.int(value))
    }

    mutating func encode(_ value: Int8) throws {
        fatalError()
    }

    mutating func encode(_ value: Int16) throws {
        fatalError()
    }

    mutating func encode(_ value: Int32) throws {
        fatalError()
    }

    mutating func encode(_ value: Int64) throws {
        fatalError()
    }

    mutating func encode(_ value: UInt) throws {
        fatalError()
    }

    mutating func encode(_ value: UInt8) throws {
        fatalError()
    }

    mutating func encode(_ value: UInt16) throws {
        fatalError()
    }

    mutating func encode(_ value: UInt32) throws {
        fatalError()
    }

    mutating func encode(_ value: UInt64) throws {
        fatalError()
    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        let dumper = StateDumper()
        try value.encode(to: dumper)
        storage.push(.array(dumper.storage.container))
    }

    mutating func encode(_ value: Bool) throws {
        storage.push(.bool(value))
    }

    var codingPath: [CodingKey] = []

    var count: Int {
        return storage.container.count
    }
    var storage: StateDumperStorage

    init(storage: StateDumperStorage) {
        self.storage = storage
    }

    mutating func encodeNil() throws {
        storage.push(.nil)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    mutating func superEncoder() -> Encoder {
        fatalError()
    }

}
