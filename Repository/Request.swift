//
//  Request.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import APIModel

public protocol CanaryRequest: APIKit.Request {
    associatedtype Error: Swift.Error = APIError

    func error(from object: Any, urlResponse: URLResponse) throws -> Error
}

enum CanaryRequestError<EndpointError: Error>: Error {
    case connectionError(Error)
    case requestError(Error)
    case responseError(Error)
    case endpointError(EndpointError)
    case unexpectedError(Error)
    case dataParseError
}

extension CanaryRequest {

    public var baseURL: URL {
        return URL(string: "https://api.twitter.com/1.1/")!
    }
}

extension CanaryRequest where Response: Decodable, Error: Decodable {
    var dataParser: DataParser {
        return JSONRawDataParser()
    }
}

extension CanaryRequest where Response: Decodable {
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let decoder = JSONDecoder()
        guard let data = object as? Data else { throw CanaryRequestError<Error>.dataParseError }
        return try decoder.decode(Response.self, from: data)
    }
}

extension CanaryRequest where Error: Decodable {
    func error(from object: Any, urlResponse: URLResponse) throws -> Error {
        let decoder = JSONDecoder()
        guard let data = object as? Data else { throw CanaryRequestError<Error>.dataParseError }
        return try decoder.decode(Error.self, from: data)
    }
}

class JSONRawDataParser: DataParser {
    public var contentType: String? {
        return "application/json"
    }
    func parse(data: Data) throws -> Any {
        return data
    }
}
