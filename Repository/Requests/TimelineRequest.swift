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

public protocol TimelineRequest: PagenatableRequest {
    static func timeline(from response: Response) -> [Tweet]
}

extension TimelineRequest where Response == [Tweet] {
    public static func timeline(from response: Response) -> [Tweet] {
        return response
    }
}

public struct HomeTimelineRequest: PagenatableRequest, TimelineRequest {
    public typealias Error = APIError
    public typealias Response = [Tweet]
    public typealias PageToken = TimelinePageToken

    public let path: String = "statuses/home_timeline.json"
    public let method: HTTPMethod = .get

    public init() {}
}

public struct UserTimelineRequest: PagenatableRequest, TimelineRequest {
    public typealias Error = APIError
    public typealias Response = [Tweet]
    public typealias PageToken = TimelinePageToken

    public let path: String = "statuses/user_timeline.json"
    public let method: HTTPMethod = .get
    public let queryParameters: [String : Any]?

    public init(userId: Int) {
        queryParameters = [
            "user_id": userId
        ]
    }

    public init(screenName: String) {
        queryParameters = [
            "screen_name": screenName
        ]
    }
}

public struct SearchRequest: PagenatableRequest, TimelineRequest {
    public typealias Error = APIError
    public struct Response: Decodable {
        public let statuses: [Tweet]
    }
    public typealias PageToken = TimelinePageToken

    public let path: String = "search/tweets.json"
    public let method: HTTPMethod = .get
    public let queryParameters: [String : Any]?

    public init(query: String) {
        queryParameters = [
            "q": query
        ]
    }

    public func nextToken(for response: SearchRequest.Response) -> TimelinePageToken {
        guard let id = response.statuses.last?.id else { return .tail }
        return .hasNext(id)
    }

    public static func timeline(from response: SearchRequest.Response) -> [Tweet] {
        return response.statuses
    }
}
