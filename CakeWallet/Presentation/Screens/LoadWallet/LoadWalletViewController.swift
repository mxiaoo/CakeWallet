//
//  LoadWalletViewController.swift
//  Wallet
//
//  Created by Cake Technologies 11/23/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class LoadWalletViewController: BaseViewController<BaseView> {
    
    // MARK: Property injections
    
    var onLogined: VoidEmptyHandler
    var onShowWalletsScreen: VoidEmptyHandler
    var onRecoveryWallet: ((String) -> Void)?
    private let walletName: String
    private let wallets: WalletsLoadable
    private let verifyPasswordViewController: VerifyPinPasswordViewController
    
    init(walletName: String, wallets: WalletsLoadable, verifyPasswordViewController: VerifyPinPasswordViewController) {
        self.walletName = walletName
        self.wallets = wallets
        self.verifyPasswordViewController = verifyPasswordViewController
        super.init()
        configureView()
    }
    
    override func configureBinds() {
        verifyPasswordViewController.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }
        verifyPasswordViewController.onVerified = {
            let alert = UIAlertController.showSpinner(message: localize("LOAD_WALLET_SCREEN_LOADING", self.walletName))
            self.present(alert, animated: true)
            
            self.wallets.loadWallet(withName: self.walletName)
                .then { [weak self] in
                    alert.dismiss(animated: true) {
                        self?.onLogined?()
                    }
                }.catch { [weak self] error in
                    print("error \(error)")
                    
                    alert.dismiss(animated: true) {
                        if let error = error as? AuthenticationError {
                            self?.showError(error)
                            return
                        }
                        
                        if error.localizedDescription == "std::bad_alloc" {
                            self?.recoveryWalletWithError()
                        } else {
                            self?.showWalletsList()
                        }
                    }
                }
        }
    }
    
    private func configureView() {
        view.addSubview(verifyPasswordViewController.view)
        verifyPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func recoveryWalletWithError() {
        let alert = UIAlertController(title: nil, message: localize("LOAD_WALLET_SCREEN_LOADING_ERROR_BODY"), preferredStyle: .alert)
        let recoveryAction = UIAlertAction(title: localize("LOAD_WALLET_SCREEN_RECOVER_WALLET"), style: .default) { _ in
            self.onRecoveryWallet?(self.walletName)
        }
        let walletsAction = UIAlertAction(title: localize("LOAD_WALLET_SCREEN_OPEN_ANOTHER_WALLET"), style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(recoveryAction)
        alert.addAction(walletsAction)
        present(alert, animated: true)
    }
    
    private func showWalletsList() {
        let alert = UIAlertController(title: nil, message: localize("LOAD_WALLET_SCREEN_ERROR_LOADING_ANOTHER"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: localize("OK"), style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension LoadWalletViewController: PresentableAccessView {
    var canBePresented: Bool {
        return verifyPasswordViewController.canBePresented
    }
    
    func callback() {
        verifyPasswordViewController.onVerified?()
    }
}

