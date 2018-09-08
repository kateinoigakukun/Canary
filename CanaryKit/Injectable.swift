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
