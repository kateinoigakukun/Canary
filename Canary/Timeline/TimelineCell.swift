//
//  TimelineCell.swift
//  Canary
//
//  Created by Yuta Saito on 2018/09/04.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit
import APIModel
import ReactiveSwift
import CanaryKit
import Result

@IBDesignable class TimelineCell: UITableViewCell, NibInstantiatableCell {
    @IBOutlet private weak var textView: UITextView!

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension TimelineCell: View {
    typealias State = Tweet
    typealias Action = TimelineCellAction

    func bind(state: Signal<Tweet, NoError>) -> Binder<Action> {
        let ds1 = textView.reactive.text <~ state.map(\.text)
        return Binder(action: .never, disposable: CompositeDisposable([ds1].compactMap { $0 }))
    }
}
