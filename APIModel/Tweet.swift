//
//  Tweet.swift
//  APIModel
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation

public struct Tweet: Codable, Identifiable {
    public let id: Int
    public let text: String
}
