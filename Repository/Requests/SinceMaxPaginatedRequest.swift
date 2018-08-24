//
//  SinceMaxPaginatedRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import APIModel
import APIKit

public final class SinceMaxPaginatedRequest<Base: PagenatableRequest>: PagenatedRequest {
    public typealias Error = Base.Error

    public let delegate: Base
    public init(base: Base, page: Base.PageToken) {
        self.delegate = base
    }
}

