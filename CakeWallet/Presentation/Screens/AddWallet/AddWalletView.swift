//
//  SignInView.swift
//  Wallet
//
//  Created by Cake Technologies 25.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import SnapKit

final class AddWalletView: BaseView {
    let newWalletButton: UIButton
    let recoveryWalletButton: UIButton
    let orLabel: UILabel
    let recoveryDescriptionLabel: UILabel
    
    required init() {
        newWalletButton = PrimaryButton(title: "Create a new wallet")
        recoveryWalletButton = SecondaryButton(title: "Recover wallet")
        orLabel = UILabel(font: UIFont.avenirNextMedium(size: 15))
        recoveryDescriptionLabel = UILabel(font: UIFont.avenirNextMedium(size: 12))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        orLabel.text = "or"
        recoveryDescriptionLabel.textColor = UIColor.havenTextLightGrey
        recoveryDescriptionLabel.textAlignment = .center
        recoveryDescriptionLabel.numberOfLines = 0
        addSubview(newWalletButton)
        addSubview(recoveryWalletButton)
        addSubview(orLabel)
        addSubview(recoveryDescriptionLabel)
        
        orLabel.textColor = UIColor.havenLightGrey
        backgroundColor = UIColor.havenBlack
    }
    
    override func configureConstraints() {
        orLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        newWalletButton.snp.makeConstraints { make in
            make.bottom.equalTo(orLabel.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        recoveryWalletButton.snp.makeConstraints { make in
            make.top.equalTo(orLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        recoveryDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(recoveryWalletButton.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(recoveryDescriptionLabel.snp.height)
        }
    }
}
