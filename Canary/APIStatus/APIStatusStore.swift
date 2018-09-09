//
//  APIStatusStore.swift
//  Canary
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import CanaryKit
import ReactiveSwift
import Result
import Repository
import APIModel

enum APIStatusAction {
    case reload
}

enum APIStatusMutation {
    case setRateLimit(APIRateLimit.RateLimit)
    case setError(Error)
}

struct APIStatusState {
    var homeTimelineLimit: APIRateLimit.RateLimit?
}

class APIStatusStore: OutputStore {

    typealias Action = APIStatusAction
    typealias Mutation = APIStatusMutation
    typealias PureState = APIStatusState
    typealias Output = APIStatusState
    typealias State = OutputState<PureState, Output>

    let initialState: State = .state(.init())
    let repository: APIRepositoryType

    init(repository: APIRepositoryType) {
        self.repository = repository
    }

    func mutate(action: Action, state: State) -> SignalProducer<Mutation, NoError> {
        switch action {
        case .reload:
            return repository.rateLimit()
                .map { .setRateLimit($0.resources.statuses.homeTimeline) }
                .flatMapError { SignalProducer(value: .setError($0)) }
        }
    }

    func reduce(mutation: Mutation, state: PureState) -> APIStatusStore.State {
        switch mutation {
        case let .setRateLimit(rateLimit):
            return .result(PureState(homeTimelineLimit: rateLimit))
        case let .setError(error):
            print(error)
            return .state(state)
        }
    }
}
