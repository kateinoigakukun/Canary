//
//  TimelineRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import APIModel

public enum TimelinePageToken: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .initial:
            self = .initial
        case .tail:
            self = .tail
        case .hasNext:
            self = try .hasNext(container.decode(Tweet.ID.self, forKey: .value))
        }
    }

    enum CodingKeys: CodingKey {
        case kind
        case value
    }

    enum Kind: String, Codable {
        case initial, tail, hasNext
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .initial:
            try container.encode(Kind.initial, forKey: .kind)
        case .tail:
            try container.encode(Kind.tail, forKey: .kind)
        case .hasNext(let id):
            try container.encode(Kind.hasNext, forKey: .kind)
            try container.encode(id, forKey: .value)
        }
    }

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
    public let queryParameters: [String: Any]?

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
    public let queryParameters: [String: Any]?

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
