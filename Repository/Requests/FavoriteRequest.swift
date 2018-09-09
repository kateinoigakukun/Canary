//
//  FavoriteRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import APIModel

struct FavoriteRequest: CanaryRequest {
    typealias Response = Tweet

    let path: String = "favorites/create.json"
    let method: HTTPMethod = .post
    let queryParameters: [String: Any]?

    init(id: Tweet.ID) {
        queryParameters = [
            "id": id
        ]
    }
}
