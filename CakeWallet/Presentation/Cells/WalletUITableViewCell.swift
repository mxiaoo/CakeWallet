//
//  WalletUITableCell.swift
//  Wallet
//
//  Created by Cake Technologies 24.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class WalletUITableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        textLabel?.font = UIFont.avenirNextMedium(size: 15)
    }
    
    override func configureConstraints() {
        textLabel?.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(name: String, isWatchOnly: Bool) {
        if isWatchOnly {
            textLabel?.text = localize("WALLET_TABLE_VIEW_CELL", name)
        } else {
            textLabel?.text = name
        }
    }
}
