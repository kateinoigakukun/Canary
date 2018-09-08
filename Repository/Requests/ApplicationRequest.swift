//
//  ApplicationRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import APIModel

public struct RateLimitStatusRequest: CanaryRequest {
    public typealias Response = APIRateLimit

    public let path: String = "application/rate_limit_status.json"
    public let method: HTTPMethod = .get
    public let queryParameters: [String: Any]? = [
        "resources": "statuses"
    ]

}
