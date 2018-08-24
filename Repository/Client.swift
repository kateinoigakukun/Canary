//
//  Client.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import OAuthSwift
import ReactiveSwift

public enum ClientError: Error {
    case connectionError(Error)
    case requestError(Error)
    case responseError(Error)
}

public enum ResponseError: Error {
    case nonHTTPURLResponse(URLResponse?)
}

public protocol ClientType {
    func send(_ request: URLRequest) -> SignalProducer<(Data, HTTPURLResponse), ClientError>
}

extension OAuthSwiftClient: ClientType {

    public func send(_ request: URLRequest) -> SignalProducer<(Data, HTTPURLResponse), ClientError> {
        return SignalProducer { [unowned self] observer, disposable in
            do {
                let authorizedRequest = try self.makeRequest(request).makeRequest()
                let session = URLSession.shared
                let task = session.dataTask(with: authorizedRequest) { (data, response, error) in
                    switch (data, response, error) {
                    case (_, _, let error?):
                        observer.send(error: .connectionError(error))
                    case (let data?, let urlResponse as HTTPURLResponse, _):
                        observer.send(value: (data, urlResponse))
                    default:
                        observer.send(error: ClientError.responseError(ResponseError.nonHTTPURLResponse(response)))
                    }
                }
                task.resume()
                disposable.observeEnded {
                    task.cancel()
                }
            } catch let error {
                observer.send(error: .requestError(error))
            }
        }
    }
}
