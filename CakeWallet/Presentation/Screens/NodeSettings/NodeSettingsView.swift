//
//  NodeSettingsView.swift
//  CakeWallet
//
//  Created by Cake Technologies 10.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class NodeSettingsView: BaseView {
    let nodeAddressLabel: UITextField
    let nodePortLabel: UITextField
    let loginLabel: UITextField
    let passwordLabel: UITextField
    let saveButton: UIButton
    let descriptionLabel: UILabel
    let resetSettings: UIButton
    
    required init() {
        nodeAddressLabel = FloatingLabelTextField(placeholder: localize("NEW_NODE_SCREEN_DAEMON_ADDRESS_TITLE"))
        nodePortLabel = FloatingLabelTextField(placeholder: localize("NEW_NODE_SCREEN_DAEMON_PORT_TITLE"))
        loginLabel = FloatingLabelTextField(placeholder: localize("NEW_NODE_SCREEN_LOGIN_TITLE"))
        passwordLabel = FloatingLabelTextField(placeholder: localize("NEW_NODE_SCREEN_PASSWORD_TITLE"))
        saveButton = PrimaryButton(title: "Connect")
        descriptionLabel = UILabel(font: .avenirNextMedium(size: 12))
        resetSettings = SecondaryButton(title: localize("NEW_NODE_SCREEN_RESET_TITLE"))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        nodePortLabel.keyboardType = .numberPad
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        addSubview(nodeAddressLabel)
        addSubview(nodePortLabel)
        addSubview(loginLabel)
        addSubview(passwordLabel)
        addSubview(saveButton)
        addSubview(descriptionLabel)
        addSubview(resetSettings)
    }
    
    override func configureConstraints() {
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        nodePortLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeAddressLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(nodePortLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.5).inset(15)
            make.trailing.equalTo(passwordLabel.snp.leading).offset(-10)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.top)
            make.width.equalTo(loginLabel.snp.width)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(descriptionLabel.snp.height)
        }
        
        resetSettings.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.trailing.equalTo(self.snp.centerX).offset(-10)
            make.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.leading.equalTo(self.snp.centerX).offset(10)
            make.height.equalTo(50)
        }
    }
}
