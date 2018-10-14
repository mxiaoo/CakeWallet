//
//  UnlockViewController.swift
//  Wallet
//
//  Created by Cake Technologies 11/14/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import PromiseKit
import SnapKit

final class LoginViewController: BaseViewController<BaseView>, BiometricAuthenticationActions, BiometricLoginPresentable {
    
    // MARK: Property injections
    
    var onBiometricAuthenticate: () -> Promise<Void> {
        return account.biometricAuthentication
    }
    
    var onLogined: VoidEmptyHandler
    var onShowWalletsScreen: VoidEmptyHandler
    var onRecoveryWallet: ((String) -> Void)?
    private let account: Account & AuthenticationProtocol
    private let pinViewController: PinPasswordViewController
    
    init(account: Account & AuthenticationProtocol) {
        self.account = account
        self.pinViewController = try! container.resolve(arguments: false) as PinPasswordViewController
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinViewController.pin { [weak self] in self?.loadWallet(withPassword: $0) }
        view.addSubview(pinViewController.view)
        pinViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if account.biometricAuthenticationIsAllow() {
            biometricLogin() {
                self.onBiometricLogin()
            }
        }
    }
    
    private func onBiometricLogin() {
        let alert =  UIAlertController.showSpinner(message: localize("LOGIN_SCREEN_UNLOCKING_WALLET_TITLE"))
        present(alert, animated: true)
        
        account.loadCurrentWallet()
            .then { [weak self] in
                alert.dismiss(animated: false) {
                    self?.onLogined?()
                }
            }.catch { [weak self] error in
                alert.dismiss(animated: true) {
                    self?.pinViewController.empty()
                    self?.pinViewController.showError(error)
                }
        }
    }
    
    private func loadWallet(withPassword password: String) {
        let alert =  UIAlertController.showSpinner(message: localize("LOGIN_SCREEN_UNLOCKING_WALLET_TITLE"))
        present(alert, animated: true)
        
        account.login(withPassword: password)
            .then { [weak self] in
                alert.dismiss(animated: false) {
                    self?.onLogined?()
                }
            }.catch { [weak self] error in
                print("error \(error)")
                
                alert.dismiss(animated: true) {
                    if let error = error as? AuthenticationError {
                        self?.pinViewController.empty()
                        self?.showError(error)
                        return
                    }
                    
                    if error.localizedDescription == "std::bad_alloc" {
                        self?.recoveryWalletWithError()
                    } else {
                        self?.showWalletsList()
                    }
                    
                    self?.pinViewController.empty()
                }
        }
    }
    
    private func recoveryWalletWithError() {
        let alert = UIAlertController(title: nil, message: localize("LOAD_WALLET_SCREEN_LOADING_ERROR_BODY"), preferredStyle: .alert)
        let recoveryAction = UIAlertAction(title: localize("LOAD_WALLET_SCREEN_RECOVER_WALLET"), style: .default) { _ in
            if let walletName = self.account.currentWalletName {
                self.onRecoveryWallet?(walletName)
            } else {
                print("Current wallet is not set")
            }
        }
        let walletsAction = UIAlertAction(title: localize("LOAD_WALLET_SCREEN_OPEN_ANOTHER_WALLET"), style: .default) { _ in
            self.onShowWalletsScreen?()
        }
        alert.addAction(recoveryAction)
        alert.addAction(walletsAction)
        present(alert, animated: true)
    }
    
    private func showWalletsList() {
        let alert = UIAlertController(title: nil, message: localize("LOAD_WALLET_SCREEN_ERROR_LOADING_ANOTHER"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: localize("OK"), style: .default) { _ in
            self.onShowWalletsScreen?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

final class AuthenticateViewController: BaseViewController<BaseView>, BiometricAuthenticationActions, BiometricLoginPresentable {
    
    // MARK: Property injections
    
    var onBiometricAuthenticate: () -> Promise<Void> {
        return account.biometricAuthentication
    }
    
    var onLogined: VoidEmptyHandler
    private let account: Account & AuthenticationProtocol
    private let pinViewController: PinPasswordViewController
    
    init(account: Account & AuthenticationProtocol) {
        self.account = account
        self.pinViewController = try! container.resolve(arguments: false) as PinPasswordViewController
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinViewController.pin { [weak self] in self?.authentication(withPassword: $0) }
        view.addSubview(pinViewController.view)
        pinViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if account.biometricAuthenticationIsAllow() {
            biometricLogin() {
                self.onLogined?()
            }
        }
    }
    
    private func authentication(withPassword password: String) {
        let alert =  UIAlertController.showSpinner(message: localize("AUTHENTICATING"))
        present(alert, animated: true)
        
        account.authenticate(password: password)
            .then { [weak self] in
                alert.dismiss(animated: false) {
                    self?.onLogined?()
                }
            }.catch { [weak self] error in
                alert.dismiss(animated: true) {
                    self?.pinViewController.empty()
                    self?.pinViewController.showError(error)
                }
        }
    }
}

