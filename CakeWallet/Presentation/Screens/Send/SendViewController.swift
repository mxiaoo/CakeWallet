//
//  SendViewController.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import AVFoundation
import QRCodeReader
import FontAwesome_swift

final class SendViewController: BaseViewController<SendView> {
    private static let allSymbol = localize("ALL")
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    private let estimatedFeeCalculation: EstimatedFeeCalculable
    private let transactionCreation: TransactionCreatableProtocol
    private var priority: TransactionPriority {
        return account.transactionPriority
    }
    private var currency: Currency {
        return account.currency
    }
    private let account: Account
    private let rateTicker: RateTicker
    private var address: String
    private var amount: String
    private var wallet: WalletProtocol
    private let unlockedBalanceLabel: UILabel
    private var rateAmount: String {
        get {
            return contentView.amountInAnotherCuncurrencyTextField.text ?? ""
        }
        
        set {
            contentView.amountInAnotherCuncurrencyTextField.text = newValue
        }
    }
    private var paymentId: String {
        get {
            return contentView.paymenyIdTextField.text ?? ""
        }
        
        set {
            contentView.paymenyIdTextField.text = newValue
        }
    }
    
    convenience init(address: String, amount: Amount, account: Account, estimatedFeeCalculation: EstimatedFeeCalculable, transactionCreation: TransactionCreatableProtocol, rateTicker: RateTicker) {
        self.init(account: account, estimatedFeeCalculation: estimatedFeeCalculation, transactionCreation: transactionCreation, rateTicker: rateTicker)
        setAddress(address)
        setAmount(amount)
    }
    
    init(account: Account, estimatedFeeCalculation: EstimatedFeeCalculable, transactionCreation: TransactionCreatableProtocol, rateTicker: RateTicker) {
        self.account = account
        self.wallet = account.currentWallet
        self.estimatedFeeCalculation = estimatedFeeCalculation
        self.transactionCreation = transactionCreation
        self.rateTicker = rateTicker
        address = ""
        amount = ""
        unlockedBalanceLabel = UILabel(font: .avenirNextMedium(size: 15))
        super.init()
    }
    
    override func configureDescription() {
        title = localize("SEND_SCREEN_NAV_TITLE")
        updateTabBarIcon(name: .paperPlane)
    }

    override func configureBinds() {
        unlockedBalanceLabel.numberOfLines = 0
        
        wallet.observe { [weak self] (change, wallt) in
            switch change {
            case let .changedUnlockedBalance(unlockedBalance):
                self?.updateUnlockedBalance(unlockedBalance)
            default:
                break
            }
        }
        
        calculateEstimatedFee()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: unlockedBalanceLabel)
        updateUnlockedBalance(wallet.unlockedBalance)
        contentView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        contentView.qrScanButton.addTarget(self, action: #selector(scanAddressFromQr), for: .touchUpInside)
        contentView.addressTextField.addTarget(self, action: #selector(onAddressTextChange(_:)), for: .editingChanged)
        contentView.amountInMoneroTextField.addTarget(self, action: #selector(onAmountTextChange(_:)), for: .editingChanged)
        contentView.amountInAnotherCuncurrencyTextField.addTarget(self, action: #selector(onAlternativeAmountTextChange(_:)), for: .editingChanged)
        contentView.allAmountButton.addTarget(self, action: #selector(setAllAmount), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateEstimatedFee()
        contentView.amountInAnotherCuncurrencyTextField.title = "\(currency.stringify().uppercased()) (\(localize("APPROXIMATE").lowercased())"
        contentView.amountInAnotherCuncurrencyTextField.placeholder = "\(currency.stringify().uppercased()): 0.00"
        contentView.feePriorityDescriptionLabel.text = localize("SEND_SCREEN_FEE_PRIORITY_DESCRIPTION", priority.stringify())
    }
    
    private func updateUnlockedBalance(_ unlockedBalance: Amount) {
        unlockedBalanceLabel.text = "XHV \(unlockedBalance.formatted())"
    }
    
    @objc
    private func scanAddressFromQr() {
        readerVC.completionBlock = { [weak self] result in
            if let value = result?.value {
                let result = MoneroQRResult(value: value)
                self?.setAddress(result.address)
                
                if let amount = result.amount {
                    self?.setAmount(amount)
                }
                
                self?.setPaymentId(result.paymentId)
            }
            
            self?.readerVC.stopScanning()
            self?.readerVC.dismiss(animated: true)
        }
        
        readerVC.modalPresentationStyle = .overFullScreen
        parent?.present(readerVC, animated: true)
    }
    
    @objc
    private func send() {
        let alert = UIAlertController(
            title: localize("SEND_SCREEN_CREATING_TRANSACTION"),
            message: localize("SEND_SCREEN_CONFIRM_SENDING"),
            preferredStyle: .alert)
        let ok = UIAlertAction(title: localize("SEND"), style: .default) { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this.createTransaction()
        }
        let cancel = UIAlertAction(title: localize("CANCEL"), style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        parent?.present(alert, animated: true)
    }
    
    @objc
    private func onAddressTextChange(_ textField: UITextField) {
        address = textField.text ?? ""
    }
    
    @objc
    private func onAmountTextChange(_ textField: UITextField) {
        amount = textField.text ?? ""
        rateAmount = convertXMRtoUSD(amount: amount, rate: rateTicker.rate)
    }
    
    @objc
    private func onAlternativeAmountTextChange(_ textField: UITextField) {
        rateAmount = textField.text ?? ""
        amount = convertUSDtoXMR(amount: rateAmount, rate: rateTicker.rate)
        contentView.amountInMoneroTextField.text = amount
    }
    
    @objc
    private func setAllAmount() {
        amount = localize("ALL")
        contentView.amountInMoneroTextField.text = SendViewController.allSymbol
        contentView.amountInAnotherCuncurrencyTextField.text = "--\(SendViewController.allSymbol)--"
    }
    
    private func setAmount(_ amount: Amount) {
        contentView.amountInMoneroTextField.text = amount.formatted()
        self.amount = amount.formatted()
        onAmountTextChange(contentView.amountInMoneroTextField)
    }
    
    private func setPaymentId(_ paymentId: String?) {
        contentView.paymenyIdTextField.text = paymentId
        
        if let paymentId = paymentId {
            self.paymentId = paymentId
        }
    }
    
    private func setAddress(_ address: String) {
        contentView.addressTextField.text = address
        self.address = address
    }
    
    private func createTransaction() {
        let alert = UIAlertController.showSpinner(message: localize("SEND_SCREEN_CREATING_TRANSACTION"))
        parent?.present(alert, animated: true)
        let amount = self.amount.lowercased() == SendViewController.allSymbol.lowercased()
            ? nil
            : MoneroAmount(amount: self.amount.replacingOccurrences(of: ",", with: "."))
        transactionCreation.createTransaction(
            to: address,
            withPaymentId: paymentId,
            amount: amount,
            priority: priority)
            .then(on: DispatchQueue.main) { [weak self] pendingTransaction -> Void in
                alert.dismiss(animated: true) {
                    self?.commitPendingTransaction(pendingTransaction)
                }
            }.catch(on: DispatchQueue.main) { [weak self] error in
                alert.dismiss(animated: true) {
                    self?.showError(error)
                }
        }
    }
    
    private func commitPendingTransaction(_ pendingTransaction: PendingTransaction) {
        let txDescription = pendingTransaction.description
        let alert = UIAlertController(
            title: localize("SEND_SCREEN_CONFIRM_SENDING"),
            message: localize("SEND_SCREEN_CONFIRM_SENDING_DETAILS", txDescription.amount.formatted(), txDescription.fee.formatted()),
            preferredStyle: .alert)
        let ok = UIAlertAction(title: localize("SEND"), style: .default) { _ in
            pendingTransaction.commit()
                .then(on: DispatchQueue.main) { [weak self] _ -> Void in
                    self?.resetForm()
                    self?.showSentTx(description: pendingTransaction.description)
                }.catch(on: DispatchQueue.main) { [weak self] error in
                    self?.showError(error)
                }
        }
        let cancel = UIAlertAction(title: localize("CANCEL"), style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        parent?.present(alert, animated: true)
    }
    
    private func resetForm() {
        contentView.amountInMoneroTextField.text = ""
        amount = ""
        rateAmount = ""
        contentView.addressTextField.text = ""
        address = ""
        paymentId = ""
    }
    
    private func showSentTx(description: PendingTransactionDescription) {
        let alert = UIAlertController(
            title: localize("SEND_SCREEN_TRANSACTION_CREATED"),
            message: localize("SEND_SCREEN_TRANSACTION_CREATED") + "!",
            preferredStyle: .alert)
        let ok = UIAlertAction(title: localize("OK"), style: .default)
        alert.addAction(ok)
        parent?.present(alert, animated: true)
    }
    
    private func calculateEstimatedFee() {
        estimatedFeeCalculation.calculateEstimatedFee(forPriority: priority)
            .then(on: DispatchQueue.main) { [weak self] amount -> Void in
                let estimatedValue: String
                
                if
                    let rate = self?.rateTicker.rate,
                    let currency = self?.currency {
                    let ratedAmount = convertXMRtoUSD(amount: amount.formatted(), rate: rate)
                    estimatedValue = "XHV \(amount.formatted()) (\(currency.symbol) \(ratedAmount))"
                } else {
                    estimatedValue = "XHV \(amount.formatted())"
                }
                
                self?.contentView.estimatedValueLabel.text = estimatedValue
            }.catch(on: DispatchQueue.main) { [weak self] error in
                self?.showError(error)
        }
    }
}


