//
//  UIViewController+Ex.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import Result

extension UIViewController: CanaryExtensionCompatible {}
extension Canary where Base: UIViewController {

    public func present<V, S>(_ viewControllerToPresent: V, animated flag: Bool, store: S)
        -> SignalProducer<S.Output, NoError> where
        V: UIViewController, V: View, S: OutputStore,
        V.State == S.PureState,
        V.Action == S.Action {
            let (state, disposable) = viewControllerToPresent.inject(store: store, mapState: { $0.state })
            base.present(viewControllerToPresent, animated: flag)
            return state.filterMap { $0.result }
                .take(first: 1)
                .producer
                .flatMap(.concat) { result in
                    viewControllerToPresent.canary.dismiss(animated: flag).map(value: result)
                }
                .on(terminated: { disposable.dispose() })
    }

    public func dismiss(animated flag: Bool) -> SignalProducer<Void, NoError> {
        let (output, input) = Signal<Void, NoError>.pipe()

        base.dismiss(animated: flag) {
            input.send(value: ())
            input.sendCompleted()
        }
        return output.producer
    }
}
