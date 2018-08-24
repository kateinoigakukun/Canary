//
//  Injectable.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

public protocol Injectable {

    associatedtype Dependency

    func inject(with dependency: Dependency)
}

extension Canary where Base: UIViewController, Base: Injectable, Base: StoryboardInstantiatable {
    public static func instantiate(with dependency: Base.Dependency) -> Base {
        let vc = instantiate()
        vc.inject(with: dependency)
        return vc
    }
}

extension Canary where Base: UIViewController, Base: Injectable, Base: StoryboardInstantiatable, Base.Dependency == Void {
    public static func instantiate() -> Base {
        return instantiate(with: ())
    }
}
