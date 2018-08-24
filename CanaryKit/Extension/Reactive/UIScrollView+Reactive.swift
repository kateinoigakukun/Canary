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
}
