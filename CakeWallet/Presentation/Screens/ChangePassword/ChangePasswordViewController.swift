//
//  ChangePasswordViewController.swift
//  Wallet
//
//  Created by Cake Technologies 11/17/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class ChangePasswordViewController: BaseViewController<BaseView> {
    
    // MARK: Property injections
    
    var onPasswordChanged: VoidEmptyHandler
    private let pinPasswordViewController: PinPasswordViewController
    private let account: Account & AuthenticationProtocol
    private var oldPassword: String
    private var newPassword: String
    
    init(account: Account & AuthenticationProtocol, pinPasswordViewController: PinPasswordViewController) {
        self.account = account
        self.pinPasswordViewController = pinPasswordViewController
        newPassword = ""
        oldPassword = ""
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinPasswordViewController.descriptionText = localize("CHANGE_PASSWORD_SCREEN_DESCRIPTION")
        pinPasswordViewController.onCloseHandler = { [weak self] in self?.dismiss(animated: true) }
        pinPasswordViewController.pin { [weak self] pinPassword in
            guard
                let oldPassword = self?.oldPassword,
                let newPassword = self?.newPassword,
                let account = self?.account else {
                    return
            }
            
            if oldPassword.isEmpty {
                account.authenticate(password: pinPassword)
                    .then { _ -> Void in
                        self?.oldPassword = pinPassword
                        self?.pinPasswordViewController.empty()
                        self?.pinPasswordViewController.descriptionText = localize("CHANGE_PASSWORD_SCREEN_ENTER_NEW_PIN")
                    }.catch { error in
                        self?.pinPasswordViewController.empty()
                        self?.showError(error)
                }
                
                return
            } else {
                if newPassword.isEmpty {
                    self?.newPassword = pinPassword
                    self?.pinPasswordViewController.empty()
                    self?.pinPasswordViewController.descriptionText = localize("CHANGE_PASSWORD_SCREEN_REPEAT_NEW_PIN")
                    return
                }
            }
            
            self?.account.change(password: pinPassword, oldPassword: oldPassword)
                .then(on: DispatchQueue.main) { _ -> Void in
                    self?.showSuccessAlert()
                }.catch(on: DispatchQueue.main) { error in
                    self?.reset()
                    self?.showError(error)
            }
        }
        
        view.addSubview(pinPasswordViewController.view)
        
        pinPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: nil, message: localize("CHANGE_PASSWORD_SCREEN_SUCCESS"), preferredStyle: .alert)
        let ok = UIAlertAction(title: localize("OK"), style: .default) { [weak self] _ in
            self?.reset()
            self?.onPasswordChanged?()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func reset() {
        pinPasswordViewController.empty()
        pinPasswordViewController.descriptionText = localize("PIN_SCREEN_ENTER_PIN")
        oldPassword = ""
    }
}

