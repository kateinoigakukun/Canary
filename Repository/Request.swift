//
//  Request.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit

public protocol CanaryRequest: APIKit.Request {
    associatedtype Error: Swift.Error

    func error(from object: Any, urlResponse: URLResponse) -> Error
}

enum CanaryRequestError<EndpointError: Error>: Error {
    case connectionError(Error)
    case requestError(Error)
    case responseError(Error)
    case endpointError(EndpointError)
    case unexpectedError(Error)
}

extension CanaryRequest {
    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        throw error(from: object, urlResponse: urlResponse)
    }
}
