//
//  Repository.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIKit
import ReactiveSwift
import OAuthSwift

public protocol RepositoryType {

    var client: ClientType { get }
    func send<R: CanaryRequest>(_ request: R) -> SignalProducer<R.Response, CanaryRequestError<R.Error>>
}

public extension RepositoryType {

    public func send<R: CanaryRequest>(_ request: R) -> SignalProducer<R.Response, CanaryRequestError<R.Error>> {
        do {
            let urlRequest = try request.intercept(urlRequest: request.buildURLRequest())
            return self.client.send(urlRequest)
                .mapError { error -> CanaryRequestError<R.Error> in
                    switch error {
                    case .requestError(let error):
                        return .requestError(error)
                    case .responseError(let error):
                        return .responseError(error)
                    case .connectionError(let error):
                        return .connectionError(error)
                    }
                }
                .flatMap(.concat) { (data, urlResponse) -> SignalProducer<(Any, HTTPURLResponse), CanaryRequestError<R.Error>> in
                    do {
                        let parsedObject = try request.dataParser.parse(data: data)
                        return SignalProducer(value: (parsedObject, urlResponse))
                    } catch {
                        return SignalProducer(error: .unexpectedError(error))
                    }
                }
                .flatMap(.concat) { parsedObject, urlResponse -> SignalProducer<(Any, HTTPURLResponse), CanaryRequestError<R.Error>> in
                    do {
                        let passedObject = try request.intercept(object: parsedObject, urlResponse: urlResponse)
                        return SignalProducer(value: (passedObject, urlResponse))
                    } catch {
                        do {
                            let error = try request.error(from: parsedObject, urlResponse: urlResponse)
                            return SignalProducer(error: .endpointError(error))
                        } catch {
                            return SignalProducer(error: .unexpectedError(error))
                        }
                    }
                }
                .flatMap(.concat, { (passedObject, urlResponse) -> SignalProducer<R.Response, CanaryRequestError<R.Error>> in
                    do {
                        let response = try request.response(from: passedObject, urlResponse: urlResponse)
                        return SignalProducer(value: response)
                    } catch {
                        return SignalProducer(error: .unexpectedError(error))
                    }
                })
        } catch {
            return SignalProducer(error: .requestError(error))
        }
    }
}
