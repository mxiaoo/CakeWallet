//
//  MnemoticViewController.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class SeedViewController: BaseViewController<SeedView> {
    
    // MARK: Property injections
    
    var finishHandler: VoidEmptyHandler
    private var walletIndex: WalletIndex?
    private let seed: String
    private let name: String
    
    convenience init(wallet: WalletProtocol) {
        self.init(seed: wallet.seed, name: wallet.name)
    }
    
    init(seed: String, name: String) {
        self.seed = seed
        self.name = name
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func configureBinds() {
        title = localize("SEED_SCREEN_NAV_TITLE")
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showMenu))
        navigationItem.rightBarButtonItem = shareButton
        contentView.seedTextView.text = seed
        contentView.nameLabel.text = name
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
    }
    
    @objc
    private func close() {
        finishHandler?()
    }
    
    // FIX-ME: Refactor me please...
    
    @objc
    private func showMenu() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: localize("CANCEL"), style: .cancel)
        let copyAction = UIAlertAction(title: localize("COPY"), style: .default) { _ in
            UIPasteboard.general.string = self.seed
        }
        let shareAction = UIAlertAction(title: localize("SHARE"), style: .default) { _ in
            let activityViewController = UIActivityViewController(
                activityItems: [self.seed],
                applicationActivities: nil)
            activityViewController.excludedActivityTypes = [
                UIActivityType.message, UIActivityType.mail,
                UIActivityType.print, UIActivityType.copyToPasteboard]
            self.present(activityViewController, animated: true)
        }
        
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.addAction(copyAction)
        alertViewController.addAction(shareAction)
        alertViewController.addAction(cancelAction)
        present(alertViewController, animated: true)
    }
}
