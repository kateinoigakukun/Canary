//
//  TimelineCellStore.swift
//  Canary
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import APIModel
import Result
import ReactiveSwift
import CanaryKit
import Repository

enum TimelineCellAction {
    case like
}

enum TimelineCellMutation {
    case setLiked(Bool)
    case error(Error)
}

class TimelineCellStore: Store {
    typealias State = Tweet
    typealias Action = TimelineCellAction
    typealias Mutation = TimelineCellMutation

    let initialState: Tweet
    let repository: APIRepositoryType

    init(tweet: Tweet, repository: APIRepositoryType) {
        self.initialState = tweet
        self.repository = repository
    }

    func mutate(action: TimelineCellAction, state: Tweet) -> SignalProducer<TimelineCellMutation, NoError> {
        switch action {
        case .like:
            return repository.like(for: state)
                .map(value: TimelineCellMutation.setLiked(true))
                .flatMapError { SignalProducer(value: .error($0)) }
        }
    }

    func reduce(mutation: TimelineCellMutation, state: Tweet) -> Tweet {
        switch mutation {
        case let .setLiked(isLiked):
            return state
        case .error:
            return state
        }
    }
}
