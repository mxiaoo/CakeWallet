//
//  SignInViewController.swift
//  Wallet
//
//  Created by Cake Technologies 25.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class AddWalletViewController: BaseViewController<AddWalletView> {
    
    // MARK: Property injections
    
    var presentCreateNewWallet: VoidEmptyHandler
    var presentRecoveryWallet: VoidEmptyHandler
    
    override init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
    }
    
    override func configureBinds() {
        title = localize("CREATE_NEW_WALLET_NAV_TITLE")
        contentView.newWalletButton.addTarget(self, action: #selector(createNewWallet), for: .touchUpInside)
        contentView.recoveryWalletButton.addTarget(self, action: #selector(recoveryNewWallet), for: .touchUpInside)
        
        // FIX-ME: Unnamed constant
        
        contentView.recoveryDescriptionLabel.text = localize("CREATE_NEW_WALLET_RECOVERY_DESCRIPTION")
    }
   
    @objc
    private func close() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc
    private func createNewWallet() {
        presentCreateNewWallet?()
    }
    
    @objc
    private func recoveryNewWallet() {
        presentRecoveryWallet?()
    }
}
