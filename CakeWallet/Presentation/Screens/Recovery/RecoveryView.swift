//
//  RecoveryView.swift
//  Wallet
//
//  Created by Cake Technologies 15.10.17.
//  Copyright © 2017 Cake Technologies. 
//w

import UIKit
import SnapKit

final class RecoveryView: BaseView {
    let walletNameTextField: UITextField
    let seedTextView: UITextView
    let confirmButton: UIButton
    let placeholderLabel : UILabel
    let restoreFromHeightView: RestoreFromHeightView
    
    required init() {
        walletNameTextField = FloatingLabelTextField(placeholder: localize("RECOVERY_SCREEN_WALLET_NAME_PLACEHOLDER"), title: localize("RECOVERY_SCREEN_WALLET_NAME_TITLE"))
        seedTextView = UITextView()
        confirmButton = PrimaryButton(title: localize("RECOVERY_SCREEN_CONFIRM_BUTTON_TITLE"))
        placeholderLabel = UILabel()
        restoreFromHeightView = RestoreFromHeightView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        seedTextView.delegate = self
       
        placeholderLabel.text = localize("RECOVERY_SCREEN_SEED_NAME_PLACEHOLDER")
        placeholderLabel.sizeToFit()
        seedTextView.addSubview(placeholderLabel)
        placeholderLabel.textColor = UIColor.havenTextLightGrey
        placeholderLabel.isHidden = !seedTextView.text.isEmpty
        
        seedTextView.font = .avenirNextMedium(size: 15)
        seedTextView.backgroundColor = .groupTableViewBackground
        seedTextView.layer.masksToBounds = true
        seedTextView.layer.cornerRadius = 10
        
        addSubview(walletNameTextField)
        addSubview(seedTextView)
        addSubview(confirmButton)
        addSubview(restoreFromHeightView)
    }
    
    override func configureConstraints() {
        placeholderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
        
        seedTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(150)
        }
        
        restoreFromHeightView.snp.makeConstraints { make in
            make.bottom.equalTo(seedTextView.snp.top).offset(-20)
            make.width.equalTo(seedTextView.snp.width)
            make.leading.equalToSuperview().offset(20)
        }
        
        walletNameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(restoreFromHeightView.snp.top).offset(-20)
            make.leading.equalTo(seedTextView.snp.leading)
            make.trailing.equalTo(seedTextView.snp.trailing)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
}

extension RecoveryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
