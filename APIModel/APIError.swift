//
//  APIError.swift
//  APIModel
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation

public struct APIError: Error, Decodable {
    public struct Error: Decodable {
        public let code: Int
        public let message: String
    }

    public let errors: [Error]
}
