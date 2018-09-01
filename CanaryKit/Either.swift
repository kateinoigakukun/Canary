//
//  Either.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/27.
//  Copyright © 2018年 bangohan. All rights reserved.
//

public enum Either<T1, T2> {
    case left(T1), right(T2)
}
