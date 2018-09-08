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

public final class SinceMaxPaginatedRequest<Base: PagenatableRequest>: PagenatedRequest where Base.PageToken == TimelinePageToken {
    public typealias Error = Base.Error

    public var queryParameters: [String: Any]? {
        switch pageToken {
        case .initial, .tail:
            return base.queryParameters
        case .hasNext(let id):
            return base.queryParameters?.merging(["max_id": id], uniquingKeysWith: { $1 })
        }
    }

    public let pageToken: Base.PageToken
    public let base: Base
    public init(base: Base, page: Base.PageToken) {
        self.base = base
        self.pageToken = page
    }
}
