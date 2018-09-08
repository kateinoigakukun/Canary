//
//  APIRateLimit.swift
//  APIModel
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation

public struct APIRateLimit: Codable {
    public struct RateLimit: Codable {
        public let limit: Int
        public let remaining: Int
        public let reset: Date
    }

    public struct Resources: Codable {

        enum CodingKeys: CodingKey {
            case statuses
        }

        public struct Statuses: Codable {
            enum CodingKeys: String, CodingKey {
                case homeTimeline = "/statuses/home_timeline"
            }
            public let homeTimeline: RateLimit
        }

        public let statuses: Statuses
    }

    public let resources: Resources
}
