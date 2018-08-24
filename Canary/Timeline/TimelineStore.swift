//
//  TimelineStore.swift
//  Canary
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import CanaryKit
import APIModel
import ReactiveSwift
import Result
import Repository

class TimelineStore: Store {

    enum Action {
        case reload
        case next
    }
    enum Mutation {
        case setTimeline([Tweet])
        case addTimeline([Tweet])
        case setPageToken(TimelinePageToken)
        case setError(Error)
    }

    struct State {
        var timeline: [Tweet]
        var pageToken: TimelinePageToken
    }

    let repository: PagingReposioty<SinceMaxPaginatedRequest<HomeTimelineRequest>>
    let initialState: TimelineStore.State = .init(timeline: [], pageToken: .initial)

    init(repository: PagingReposioty<SinceMaxPaginatedRequest<HomeTimelineRequest>>) {
        self.repository = repository
    }

    func mutate(action: Action, state: State) -> SignalProducer<Mutation, NoError> {
        switch action {
        case .reload:
            return repository.request(page: .initial)
                .flatMap(.concat) { SignalProducer([.setPageToken($1), .setTimeline($0)]) }
                .flatMapError { SignalProducer(value: .setError($0)) }
        case .next:
            return repository.request(page: state.pageToken)
                .flatMap(.concat) { SignalProducer([.setPageToken($1), .addTimeline($0)]) }
                .flatMapError { SignalProducer(value: .setError($0)) }
        }
    }

    func reduce(mutation: Mutation, state: State) -> State {
        var state = state
        switch mutation {
        case .setTimeline(let timeline):
            state.timeline = timeline
        case .addTimeline(let timeline):
            state.timeline += timeline
        case .setPageToken(let pageToken):
            state.pageToken = pageToken
        case .setError(let error):
            print(error)
        }
        return state
    }
}
