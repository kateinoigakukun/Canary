//
//  DelegatedRequest.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation
import APIKit

public protocol DelegatedRequest: CanaryRequest where Response == Base.Response, Error == Base.Error {
    associatedtype Base: CanaryRequest

    var delegate: Base { get }
}

extension DelegatedRequest {
    public var baseURL: URL { return delegate.baseURL }
    public var path: String { return delegate.path }
    public var method: HTTPMethod { return delegate.method }
    public var parameters: Any? { return delegate.parameters }
    public var queryParameters: [String: Any]? { return delegate.queryParameters }
    public var bodyParameters: BodyParameters? { return delegate.bodyParameters }
    public var headerFields: [String: String] { return delegate.headerFields }
    public var dataParser: DataParser { return delegate.dataParser }

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Base.Response {
        return try delegate.response(from: object, urlResponse: urlResponse)
    }

    public func error(from object: Any, urlResponse: URLResponse) throws -> Error {
        return try delegate.error(from: object, urlResponse: urlResponse)
    }

    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return try delegate.intercept(urlRequest: urlRequest)
    }

    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        return try delegate.intercept(object: object, urlResponse: urlResponse)
    }
}
