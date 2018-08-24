//
//  TimelineRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import APIModel

struct TimelineRequest: CanaryRequest {
    typealias Error = APIError
    typealias Response = [Tweet]

    let path: String = "statuses/home_timeline.json"
    let method: HTTPMethod = .get
}
