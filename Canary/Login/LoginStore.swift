//
//  LoginStore.swift
//  Canary
//
//  Created by Yuta Saito on 2018/09/04.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import CanaryKit
import Result

enum LoginAction {
    case login
}

enum LoginMutation {
    case setUserToken(UserToken)
}

enum LoginState {
    case idle
    case loading
    case logined(UserToken)
}

struct UserToken {
}

class LoginStore: OutputStore {
    typealias Action = LoginAction
    typealias Mutation = LoginMutation
    typealias PureState = LoginState
    typealias Output = UserToken
    typealias State = OutputState<PureState, Output>

    let initialState: State = .state(.idle)

    func mutate(action: Action, state: State) -> SignalProducer<Mutation, NoError> {
        switch action {
        case .login: fatalError()
        }
    }

    func reduce(mutation: Mutation, state: PureState) -> State {
        switch mutation {
        case .setUserToken(let userToken):
            return .result(userToken)
        }
    }
}
