//
//  TimelineCell.swift
//  Canary
//
//  Created by Yuta Saito on 2018/09/04.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit
import APIModel
import CanaryKit

@IBDesignable class TimelineCell: UITableViewCell, NibInstantiatableCell, Injectable {
    @IBOutlet private weak var textView: UITextView!

    typealias Dependency = Tweet

    func inject(with dependency: Dependency) {
        textView.text = dependency.text
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}
