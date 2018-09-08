//
//  Instantiatable.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation

public protocol XibInstantiatable {
    static var xibName: String { get }
}

extension XibInstantiatable {
    public static var xibName: String {
        return String(describing: Self.self)
    }
}
