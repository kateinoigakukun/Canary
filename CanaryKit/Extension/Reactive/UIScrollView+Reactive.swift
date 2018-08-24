//
//  UIScrollView+Reactive.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

extension Reactive where Base: UIScrollView {
    public var contentOffset: Signal<CGPoint, NoError> {
        return signal(forKeyPath: #function).map { $0 as! CGPoint }
    }

    public var reachedBottom: Signal<Void, NoError> {
        return contentOffset
        .filter { [weak base] contentOffset in
            guard let scrollView = base else {
                return false
            }
            let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
            let y = contentOffset.y + scrollView.contentInset.top
            let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
            return y > threshold
        }
        .map(value: Void())
    }
}
