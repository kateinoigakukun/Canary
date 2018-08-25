//
//  Pagenation.swift
//  Repository
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import Foundation
import APIKit
import APIModel
import ReactiveSwift

public protocol PagenatableRequest: CanaryRequest {
    associatedtype PageToken
    func nextToken(for response: Response) -> PageToken
}

extension PagenatableRequest where Response: RandomAccessCollection, Response.Element == Tweet, PageToken == TimelinePageToken {
    public func nextToken(for response: Response) -> PageToken {
        guard let id = response.last?.id else {
            return .tail
        }
        return .hasNext(id)
    }
}

public protocol PagenatedRequest: DelegatedRequest where Base: PagenatableRequest {

    init(base: Base, page: Base.PageToken)

    func nextToken(for response: Response) -> Base.PageToken
}

extension PagenatedRequest {
    public func nextToken(for response: Response) -> Base.PageToken {
        return delegate.nextToken(for: response)
    }
}

public class PagingReposioty<Request: PagenatedRequest>: RepositoryType {

    public typealias Page = Request.Base.PageToken
    public let initialRequest: Request.Base
    public let client: ClientType

    public init(initialRequest: Request.Base, client: ClientType) {
        self.initialRequest = initialRequest
        self.client = client
    }

    public func request(page: Page) -> SignalProducer<(Request.Response, Page), CanaryRequestError<Request.Error>> {
        let request = Request(base: initialRequest, page: page)
        return send(request).map { ($0, request.nextToken(for: $0)) }
    }
}
