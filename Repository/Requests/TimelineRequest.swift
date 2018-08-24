//
//  TimelineRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import APIModel

public enum TimelinePageToken {
    case initial
    case hasNext(Tweet.ID)
    case tail
}

public struct HomeTimelineRequest: PagenatableRequest {
    public typealias Error = APIError
    public typealias Response = [Tweet]
    public typealias PageToken = TimelinePageToken

    public let path: String = "statuses/home_timeline.json"
    public let method: HTTPMethod = .get

    public init() {}
}
