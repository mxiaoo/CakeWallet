//
//  RecoveryWalletOptionsViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 14.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class RecoveryWalletOptionsViewController: BaseViewController<RecoveryWalletOptionsView> {
    
    // MARK: Property injections
    
    var presentRecoveryFromSeed: VoidEmptyHandler
    var presentRecoveryFromKeys: VoidEmptyHandler
    
    override init() {
        super.init()
    }
    
    override func configureBinds() {
        title = localize("RECOVERY_WALLET_OPTIONS_SCREEN_NAV_TITLE")
        contentView.orLabel.text = localize("OR")
        contentView.seedButton.addTarget(self, action: #selector(onRecoveryFromSeed), for: .touchUpInside)
        contentView.keysButton.addTarget(self, action: #selector(onRecoveryFromKeys), for: .touchUpInside)
    }
    
    @objc
    private func onRecoveryFromSeed() {
        self.presentRecoveryFromSeed?()
    }
    
    @objc
    private func onRecoveryFromKeys() {
        self.presentRecoveryFromKeys?()
    }
}
