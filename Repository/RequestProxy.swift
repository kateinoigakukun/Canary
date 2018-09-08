//
//  RequestProxy.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation
import APIKit

public protocol RequestProxy: CanaryRequest where Response == Base.Response, Error == Base.Error {
    associatedtype Base: CanaryRequest

    var base: Base { get }
}

extension RequestProxy {
    public var baseURL: URL { return base.baseURL }
    public var path: String { return base.path }
    public var method: HTTPMethod { return base.method }
    public var parameters: Any? { return base.parameters }
    public var queryParameters: [String: Any]? { return base.queryParameters }
    public var bodyParameters: BodyParameters? { return base.bodyParameters }
    public var headerFields: [String: String] { return base.headerFields }
    public var dataParser: DataParser { return base.dataParser }

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Base.Response {
        return try base.response(from: object, urlResponse: urlResponse)
    }

    public func error(from object: Any, urlResponse: URLResponse) throws -> Error {
        return try base.error(from: object, urlResponse: urlResponse)
    }

    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return try base.intercept(urlRequest: urlRequest)
    }

    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        return try base.intercept(object: object, urlResponse: urlResponse)
    }
}
