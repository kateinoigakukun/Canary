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

enum TimelineAction {
    case reload
    case next
}

enum TimelineMutation {
    case setTimeline([Tweet])
    case addTimeline([Tweet])
    case setLoading(Bool)
    case setPageToken(TimelinePageToken)
    case setError(Error)
}

struct TimelineState {
    var timeline: [Tweet]
    var pageToken: TimelinePageToken
    var isLoading: Bool
    let repository: APIRepositoryType

    var sections: [Section] {
        return [.timeline(timeline.map { Section.Row(tweet: $0, repository: repository) })]
    }

    enum Section: SectionType {
        struct Row {
            let tweet: Tweet
            let repository: APIRepositoryType
            var store: TimelineCellStore {
                return TimelineCellStore(tweet: tweet, repository: repository)
            }
        }

        case timeline([Row])
        var rows: [Row] {
            switch self {
            case .timeline(let timeline):
                return timeline
            }
        }
    }
}

class TimelineStore<Request: PagenatedRequest>: Store where Request.Base.PageToken == TimelinePageToken, Request.Base: TimelineRequest {

    typealias Action = TimelineAction
    typealias Mutation = TimelineMutation
    typealias State = TimelineState

    let repository: PagingReposioty<Request>
    let initialState: TimelineStore.State

    init(repository: PagingReposioty<Request>, apiRepository: APIRepositoryType) {
        self.repository = repository
        initialState = .init(timeline: [], pageToken: .initial, isLoading: false, repository: apiRepository)
    }

    func mutate(action: Action, state: State) -> SignalProducer<Mutation, NoError> {
        switch action {
        case .reload:
            return SignalProducer(value: .setLoading(true)).concat(
                repository.request(page: .initial)
                    .take(first: 1)
                    .flatMap(.concat) {
                        SignalProducer(
                            [
                                .setPageToken($1),
                                .setTimeline(Request.Base.timeline(from: $0)),
                                .setLoading(false)
                            ]
                        )
                    }
                    .flatMapError { SignalProducer(value: .setError($0)) }
            )
        case .next:
            return SignalProducer(value: .setLoading(true)).concat(
                repository.request(page: state.pageToken)
                    .take(first: 1)
                    .flatMap(.concat) {
                        SignalProducer(
                            [
                                .setPageToken($1),
                                .addTimeline(Request.Base.timeline(from: $0)),
                                .setLoading(false)
                            ]
                        )
                    }
                    .flatMapError { SignalProducer(value: .setError($0)) }
            )
        }
    }

    func reduce(mutation: Mutation, state: State) -> State {
        var state = state
        switch mutation {
        case .setTimeline(let timeline):
            state.timeline = timeline
        case .addTimeline(let timeline):
            state.timeline += timeline
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setPageToken(let pageToken):
            state.pageToken = pageToken
        case .setError(let error):
            print(error)
        }
        return state
    }
}
