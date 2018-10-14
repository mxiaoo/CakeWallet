//
//  TransactionDetailsViewController.swift
//  Wallet
//
//  Created by Cake Technologies 12/6/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class TransactionDetailsViewController: BaseViewController<TransactionDetailsView>,
                                              UITableViewDelegate,
                                              UITableViewDataSource {
    enum Row: Int, Stringify {
        case id, paymentId, date, amount, height, fee
        
        func stringify() -> String {
            let str: String
            
            switch self {
            case .id:
                str = localize("ID")
            case .paymentId:
                str = localize("PAYMENTID")
            case .date:
                str = localize("DATE")
            case .amount:
                str = localize("AMOUNT")
            case .fee:
                str = localize("FEE")
            case .height:
                str = localize("HEIGHT")
            }
            
            return str
        }
    }
    
    private let transaction: TransactionDescription
    private var rows: [Row: String]
    
    init(transaction: TransactionDescription) {
        self.transaction = transaction
        rows = [:]
        super.init()
    }
    
    override func configureBinds() {
        title = localize("TRANSACTION_DETAILS_SCREEN_NAV_TITLE")
        contentView.table.register(
            TransactionDetailsUITableViewCell.self,
            forCellReuseIdentifier: TransactionDetailsUITableViewCell.identifier)
        contentView.table.delegate = self
        contentView.table.dataSource = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm"
        
        rows[.id] = transaction.id
        rows[.date] = dateFormatter.string(from: transaction.date)
        rows[.amount] = transaction.totalAmount.formatted()
        rows[.paymentId] = transaction.paymentId
        rows[.height] = "\(transaction.height)"
        
        if transaction.direction != .incoming {
            rows[.fee] = transaction.fee.formatted()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailsUITableViewCell", for: indexPath) as? TransactionDetailsUITableViewCell,
            let row = Row(rawValue: indexPath.row),
            let value = rows[row] else {
                return UITableViewCell()
        }
        
        cell.configure(title: row.stringify(), value: value)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            copyValueFromItem(withIndexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    private func copyValueFromItem(withIndexPath indexPath: IndexPath) {
        guard
            let row = Row(rawValue: indexPath.row),
            let value = rows[row] else {
                return
        }
        
        UIPasteboard.general.string  = value
    }
}
