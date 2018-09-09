//
//  UITableView+Ex.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/09/04.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit

extension UITableView: CanaryExtensionCompatible {}

public protocol NibInstantiatableCell {
    static var cellReuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension NibInstantiatableCell {
    private static var className: String { return String(describing: Self.self) }
    public static var cellReuseIdentifier: String { return className }
    public static var nib: UINib { return UINib(nibName: className, bundle: nil) }
}

extension Canary where Base: UITableView {

    public func register<T>(forNib type: T.Type) -> RegisteredCellToken<T> where T: NibInstantiatableCell {
        base.register(type.nib, forCellReuseIdentifier: type.cellReuseIdentifier)
        return RegisteredCellToken(cellReuseIdentifier: type.cellReuseIdentifier)
    }
}

public struct RegisteredCellToken<Cell: UITableViewCell> {
    let cellReuseIdentifier: String
}

extension RegisteredCellToken where Cell: View {

    public func dequeue<S: Store>(in tableView: UITableView,
                                  for indexPath: IndexPath,
                                  store: S) -> CellProxy<S.State>
        where S.Action == Cell.Action, S.State == Cell.State
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! Cell
        let (state, disposable) = cell.inject(store: store)
        let proxy = CellProxy<S.State>(cell: cell, state: state, disposable: disposable)
        return proxy
    }
}

import Result
import ReactiveSwift

public struct CellProxy<State> {
    unowned let cell: UITableViewCell
    let disposable: Disposable
    let state: Signal<State, NoError>

    init(cell: UITableViewCell, state: Signal<State, NoError>, disposable: Disposable) {
        self.cell = cell
        self.disposable = disposable
        self.state = state
    }

    func dispose() {
        disposable.dispose()
    }
}
