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

extension RegisteredCellToken where Cell: Injectable {

    public func dequeue(in tableView: UITableView,
                        for indexPath: IndexPath,
                        dependency: Cell.Dependency) -> Cell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! Cell
        cell.inject(with: dependency)
        return cell
    }
}
