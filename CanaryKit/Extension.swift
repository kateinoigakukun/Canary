//
//  Extension.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation

public protocol CanaryExtensionCompatible {
    associatedtype Base

    var canary: Canary<Base> { get }
    static var canary: Canary<Base>.Type { get }
}

extension CanaryExtensionCompatible {
    public var canary: Canary<Self> {
        return Canary(base: self)
    }

    public static var canary: Canary<Self>.Type {
        return Canary<Self>.self
    }
}

public struct Canary<Base> {
    let base: Base
}
