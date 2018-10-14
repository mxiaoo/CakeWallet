//
//  ReceiveView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import SnapKit

final class ShadowedLabel: UILabel {
    var insets : UIEdgeInsets = UIEdgeInsets() {
        didSet {
            super.invalidateIntrinsicContentSize()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addShadowView()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
    
    override open func drawText(in rect: CGRect) {
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

extension UIView {
    func addShadowView() {
        superview?.viewWithTag(119900)?.removeFromSuperview()
        let shadowView = UIView(frame: frame)
        
        // Fix me: hardcode.
        
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 25
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true
        
        superview?.insertSubview(shadowView, belowSubview: self)
    }
}

final class ReceiveView: BaseView {
    private static var qrImageViewSize: CGSize {
        switch UIScreen.main.sizeType {
        case .iPhone5, .iPhone6:
            return CGSize(width: 130, height: 130)
        default:
            return CGSize(width: 200, height: 200)
        }
    }
    
    let qrImageView: UIImageView
    let addressLabel: UILabel
    let amountTextField: UITextField
    let paymentIdTextField: UITextField
    let integratedAddressTextField: UITextField
    let copyAddressButton: UIButton
    let copyPaymentIdButton: UIButton
    let copyIntegratedAddressButton: UIButton
    let generatePaymentIdButton: UIButton
    let innerView: UIView
    
    required init() {
        amountTextField = FloatingLabelTextField(placeholder: localize("RECEIVE_SCREEN_AMOUNT_PLACEHOLDER"), title: localize("AMOUNT"))
        qrImageView = UIImageView()
        addressLabel = UILabel(font: .avenirNextBold(size: 15))
        copyAddressButton = PrimaryButton(title: localize("RECEIVE_SCREEN_COPY_ADDRESS").uppercased())
        innerView = CardView()
        paymentIdTextField = FloatingLabelTextField(placeholder: localize("RECEIVE_SCREEN_PAYMENT_ID_PLACEHOLDER"), title: localize("RECEIVE_SCREEN_PAYMENT_ID_TITLE"))
        integratedAddressTextField = FloatingLabelTextField(placeholder: localize("RECEIVE_SCREEN_INTEGRATED_ADDRESS_PLACEHOLDER"), title: localize("RECEIVE_SCREEN_INTEGRATED_ADDRESS_TITLE"))
        generatePaymentIdButton = SecondaryButton(title: localize("RECEIVE_SCREEN_NEW_PAYMENT_ID").uppercased())
        copyPaymentIdButton = SecondaryButton(title: localize("COPY").uppercased())
        copyIntegratedAddressButton = SecondaryButton(title: localize("COPY").uppercased())
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addressLabel.numberOfLines = 0
        addressLabel.isUserInteractionEnabled = true
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        amountTextField.keyboardType = .decimalPad
        integratedAddressTextField.isUserInteractionEnabled = false
        innerView.addSubview(qrImageView)
        innerView.addSubview(addressLabel)
        innerView.addSubview(amountTextField)
        innerView.addSubview(paymentIdTextField)
        innerView.addSubview(integratedAddressTextField)
        innerView.addSubview(copyPaymentIdButton)
        innerView.addSubview(copyIntegratedAddressButton)
        backgroundColor = .havenLightGrey
        addSubview(copyAddressButton)
        addSubview(innerView)
        addSubview(generatePaymentIdButton)
    }
    
    override func configureConstraints() {
        innerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        qrImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            switch UIScreen.main.sizeType {
            case .iPhone5, .iPhone6:
                make.top.equalToSuperview().offset(10)
            default:
                make.top.equalToSuperview().offset(15)
            }
            make.width.equalTo(ReceiveView.qrImageViewSize.width)
            make.height.equalTo(ReceiveView.qrImageViewSize.height)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.width.equalTo(addressLabel.snp.width)
            make.height.equalTo(addressLabel.snp.height)
            switch UIScreen.main.sizeType {
            case .iPhone5, .iPhone6:
                make.top.equalTo(qrImageView.snp.bottom).offset(5)
            default:
                make.top.equalTo(qrImageView.snp.bottom).offset(10)
            }
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        amountTextField.snp.makeConstraints { make in
            switch UIScreen.main.sizeType {
            case .iPhone5, .iPhone6:
                make.top.equalTo(addressLabel.snp.bottom)
            default:
                make.top.equalTo(addressLabel.snp.bottom).offset(5)
            }
            
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        copyPaymentIdButton.snp.makeConstraints { make in
            make.height.equalTo(paymentIdTextField.snp.height)
            make.centerY.equalTo(paymentIdTextField.snp.centerY)
            make.width.equalTo(70)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        paymentIdTextField.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(copyPaymentIdButton.snp.leading).offset(-10)
        }
        
        copyIntegratedAddressButton.snp.makeConstraints { make in
            make.height.equalTo(integratedAddressTextField.snp.height)
            make.centerY.equalTo(integratedAddressTextField.snp.centerY)
            make.width.equalTo(70)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        integratedAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(paymentIdTextField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(copyIntegratedAddressButton.snp.leading).offset(-10)
            switch UIScreen.main.sizeType {
            case .iPhone5, .iPhone6:
                make.bottom.equalToSuperview().offset(-10)
            default:
                make.bottom.equalToSuperview().offset(-20)
            }
        }
        
        copyAddressButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.height.equalTo(50)
            make.leading.equalTo(self.snp.centerX).offset(10)
        }
        
        generatePaymentIdButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.height.equalTo(50)
            make.trailing.equalTo(self.snp.centerX).offset(-10)
        }
    }
}
