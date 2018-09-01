//
//  DebugPlugin.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/26.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import Result

//protocol DebugPlugin {
//    associatedtype Parent: View
//
//    func provide(state: Signal<Parent.State, NoError>) -> UIViewController
//}
//
//struct DebugStateEditPlugin<Parent: View, T>: DebugPlugin {
//
//    init(getter: @escaping (Parent.State) -> T, setter: @escaping (Parent.State, T) -> Parent.State) {
//    }
//
//    func provide(state: Signal<Parent.State, NoError>) -> UIViewController {
//
//    }
//
//    class ViewController<T>: UIViewController, View {
//        enum Action { case setValue(T) }
//        typealias State = T
//
//
//        override func viewDidLoad() {
//            super.viewDidLoad()
//        }
//
//        func bind(state: Signal<T, NoError>) -> Binder<Action> {
//            state.observeValues { value in
//
//            }
//        }
//    }
//}

