//
//  Identifiable.swift
//  APIModel
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

public protocol Identifiable {
    associatedtype ID
    var id: ID { get }
}
