//
//  NewNodeViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 06.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class NewNodeSettingsViewController: BaseViewController<NewNodeSettingsView> {
    private let nodesList: NodesList
    
    init(nodesList: NodesList) {
        self.nodesList = nodesList
        super.init()
    }
    
    override func configureBinds() {
        title = localize("NEW_NODE_SCREEN_NAV_TITLE")
        contentView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        contentView.resetSettings.addTarget(self, action: #selector(onResetSetting), for: .touchUpInside)
    }
    
    private func setSettings(_ settings: ConnectionSettings) {
        setAddress(fromUri: settings.uri)
        contentView.loginLabel.text = settings.login
        contentView.passwordLabel.text =  settings.password
    }
    
    private func setAddress(fromUri uri: String) {
        let splitedUri = uri.components(separatedBy: ":")
        let address = splitedUri.first ?? ""
        let port = Int(splitedUri.last ?? "") ?? 0
        
        contentView.nodeAddressLabel.text = address
        contentView.nodePortLabel.text  = "\(port)"
    }
    
    @objc
    private func onResetSetting() {
        let alert = UIAlertController(
            title: localize("RESET"),
            message: localize("NEW_NODE_SCREEN_RESET_SETTINGS_CONFIRM_DESCRIPTION"),
            preferredStyle: .alert)
        let ok = UIAlertAction(title: localize("NEW_NODE_SCREEN_RESET_SETTINGS_CONFIRM_CONFIRM_ACTION"), style: .default) { [weak self] _ in
            self?.setSettings(ConnectionSettings(uri: "", login: "", password: ""))
        }
        let cancel = UIAlertAction(title: localize("CANCEL"), style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @objc
    private func save() {
        let _alert = UIAlertController.showSpinner(message: localize("NEW_NODE_SCREEN_SAVING"))
        present(_alert, animated: true)
        
        guard
            let address = contentView.nodeAddressLabel.text,
            let port = contentView.nodePortLabel.text else {
                return
        }
        
        let uri = "\(address):\(port)"
        
        let connectionSettings = ConnectionSettings(
            uri: uri,
            login: contentView.loginLabel.text ?? "",
            password: contentView.passwordLabel.text ?? "")
        
        do {
            try nodesList.addNode(settings: connectionSettings)
            _alert.dismiss(animated: true) {
                UIAlertController.showInfo(title: nil, message: localize("NEW_NODE_SCREEN_SAVED"), presentOn: self)
            }
        } catch {
            _alert.dismiss(animated: true) { [weak self] in
                self?.showError(error)
            }
        }
    }
}
