//
//  Instantiatable.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation

public protocol StoryboardInstantiatable {
    static var storyboardName: String { get }
}

extension StoryboardInstantiatable {
    public static var storyboardName: String {
        return String(describing: Self.self)
    }
}

extension UIViewController: CanaryExtensionCompatible {}
extension Canary where Base: UIViewController, Base: StoryboardInstantiatable {
    static func instantiate() -> Base {
        let storyboard = UIStoryboard(name: Base.storyboardName, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        return vc as! Base
    }
}
