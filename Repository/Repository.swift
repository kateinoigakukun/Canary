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

protocol RepositoryType {

    func send<R: CanaryRequest>(_ request: R) -> SignalProducer<R.Response, CanaryRequestError<R.Error>>
}

class Repository: RepositoryType {

    private let client: ClientType
    private let dispatchQueue: DispatchQueue

    init(client: ClientType, dispatchQueue: DispatchQueue) {
        self.client = client
        self.dispatchQueue = dispatchQueue
    }

    func send<R: CanaryRequest>(_ request: R) -> SignalProducer<R.Response, CanaryRequestError<R.Error>> {
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
                .flatMap(.concat, { (data, urlResponse) -> SignalProducer<R.Response, CanaryRequestError<R.Error>> in
                    do {
                        let response = try request.parse(data: data, urlResponse: urlResponse)
                        return SignalProducer(value: response)
                    }
                    catch let error as R.Error {
                        return SignalProducer(error: .endpointError(error))
                    }
                    catch let error {
                        return SignalProducer(error: .unexpectedError(error))
                    }
                })
        } catch {
            return SignalProducer(error: .requestError(error))
        }
    }
}