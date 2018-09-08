//
//  APIRepository.swift
//  Repository
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIModel
import ReactiveSwift

public protocol APIRepositoryType: RepositoryType {
    typealias RepositoryError = CanaryRequestError<APIError>

    func rateLimit() -> SignalProducer<APIRateLimit, RepositoryError>
}

public class APIRepository: APIRepositoryType {

    public let client: ClientType

    public init(client: ClientType) {
        self.client = client
    }

    public func rateLimit() -> SignalProducer<APIRateLimit, RepositoryError> {
        return self.send(RateLimitStatusRequest())
    }
}
