//
//  SettingsViewController.swift
//  Wallet
//
//  Created by Cake Technologies 01.11.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import FontAwesome_swift
import SafariServices

final class SettingsViewController: BaseViewController<SettingsView>, UITableViewDelegate, UITableViewDataSource {
    enum SettingsSections: Int {
//        case donation, wallets, personal, advanced, contactUs
        
        case wallets, personal, advanced, contactUs, other
    }
    
    struct SettingsTextViewCellItem: CellItem {
        let attributedString: NSAttributedString
        
        init(attributedString: NSAttributedString) {
            self.attributedString = attributedString
        }
        
        func setup(cell: TextViewUITableViewCell) {
            cell.configure(attributedText: attributedString)
        }
    }
    
    struct SettingsCellItem: CellItem {
        let title: String
        let action: VoidEmptyHandler
        let image: UIImage?
        
        init(title: String, image: UIImage? = nil, action: VoidEmptyHandler = nil) {
            self.title = title
            self.image = image
            self.action = action
        }
        
        func setup(cell: UITableViewCell) {
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    final class SettingsSwitchCellItem: CellItem {
        let title: String
        let image: UIImage?
        let action: ((Bool) -> Void)?
        let switchView: UISwitch
        
        init(title: String, image: UIImage? = nil, isOn: Bool, action: ((Bool) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.switchView = UISwitch()
            self.switchView.isOn = isOn
            self.switchView.onTintColor = .havenGreen
            config()
        }
        
        func setup(cell: UITableViewCell) {
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryView = switchView
        }
        
        private func config() {
            switchView.addTarget(self, action: #selector(onValueChange), for: .valueChanged)
        }
        
        @objc
        private func onValueChange() {
            self.action?(self.switchView.isOn)
        }
    }
    
    struct SettingsPickerCellItem<PickerItem: Stringify>: CellItem {
        let title: String
        let image: UIImage?
        let pickerOptions: [PickerItem]
        let action: ((PickerItem) -> Void)?
        let onFinish: ((PickerItem) -> Void)?
        private var selectedIndex: Int
        
        init(title: String,
             image: UIImage? = nil,
             pickerOptions: [PickerItem],
             selectedAtIndex: Int,
             action: ((PickerItem) -> Void)? = nil,
             onFinish: ((PickerItem) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.pickerOptions = pickerOptions
            self.selectedIndex = selectedAtIndex
            self.onFinish = onFinish
        }
        
        func setup(cell: SettingsPickerUITableViewCell<PickerItem>) {
            cell.configure(title: title, pickerOptions: pickerOptions, selectedOption: selectedIndex, action: action)
            cell.imageView?.image = image
            cell.onFinish = onFinish
        }
    }
    
    // MARK: Property injections
    
    var presentChangePasswordScreen: VoidEmptyHandler
    var presentNodeSettingsScreen: VoidEmptyHandler
    var presentWalletsScreen: VoidEmptyHandler
    var presentWalletKeys: VoidEmptyHandler
    var presentWalletSeed: VoidEmptyHandler
    var presentDonation: VoidEmptyHandler
    
    private var sections: [SettingsSections: [CellAnyItem]]
    private var accountSettings: AccountSettingsConfigurable & CurrencySettingsConfigurable
    private var showSeedIsAllow: Bool
    
    init(accountSettings: AccountSettingsConfigurable & CurrencySettingsConfigurable, showSeedIsAllow: Bool) {
        self.accountSettings = accountSettings
        self.showSeedIsAllow = showSeedIsAllow
        self.sections = [.wallets: [], .personal: []]
        super.init()
    }
    
    override func configureDescription() {
        title = localize("SETTINGS_SCREEN_NAV_TITLE")
        updateTabBarIcon(name: .cog)
    }

    override func configureBinds() {
        contentView.table.register(items: [
            SettingsCellItem.self,
            SettingsPickerCellItem<TransactionPriority>.self,
            SettingsPickerCellItem<Currency>.self,
            SettingsTextViewCellItem.self])
        contentView.table.delegate = self
        contentView.table.dataSource = self
        
        if
            let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            contentView.footerLabel.text = localize("SETTINGS_SCREEN_VERSION", version)
        }
        
        let biometricAuthSwitcher = SettingsSwitchCellItem(
            title: localize("SETTINGS_SCREEN_BIOMETRIC_AUTHENTICATON_TITLE"),
            isOn: accountSettings.isBiometricalAuthAllow,
            action: { [weak self] isOn in
                self?.accountSettings.isBiometricalAuthAllow = isOn
        })
        
        let rememberPasswordSwitcher = SettingsSwitchCellItem(
            title: localize("SETTINGS_SCREEN_REMEMBER_PIN_TITLE"),
            isOn: accountSettings.isPasswordRemembered) { [weak self] isOn in
                self?.accountSettings.isPasswordRemembered = isOn
        }
        
        let options: [TransactionPriority] = [.slow, .default, .fast, .fastest]
        
        let feePriorityPicker = SettingsPickerCellItem<TransactionPriority>(
            title: localize("SETTINGS_SCREEN_FEE_PRIORITY_TITLE"),
            pickerOptions: options,
            selectedAtIndex: options.index(of: accountSettings.transactionPriority) ?? 0) { [weak self] pickedItem in
                self?.accountSettings.transactionPriority = pickedItem
        }
        
        let changePin = SettingsCellItem(
            title: localize("SETTINGS_SCREEN_CHANGE_PIN_TITLE"),
            action: { [weak self] in
                self?.presentChangePasswordScreen?()
        })
        
        let nodeSettings = SettingsCellItem(
            title: localize("SETTINGS_SCREEN_DAEMON_SETTINGS_TITLE"),
            action: { [weak self] in
                self?.presentNodeSettingsScreen?()
        })
        
        let currencyPicker = SettingsPickerCellItem<Currency>(
            title: localize("SETTINGS_SCREEN_CURRENCY_TITLE"),
            pickerOptions: Currency.all,
            selectedAtIndex: Currency.all.index(of: accountSettings.currency) ?? Configurations.defaultCurreny.rawValue,
            onFinish:  { [weak self] pickedItem in
                self?.accountSettings.currency = pickedItem
        })
        
        sections[.personal] = [
            changePin,
            biometricAuthSwitcher,
            rememberPasswordSwitcher
        ]
        
        let wallets = SettingsCellItem(
            title: localize("SETTINGS_SCREEN_ADD_OR_SWITCH_WALLET_TITLE"),
            action: { [weak self] in
                self?.presentWalletsScreen?()
        })
        
        let showKeys = SettingsCellItem(
            title: localize("SETTINGS_SCREEN_SHOW_KEYS_TITLE"),
            action: { [weak self] in
                self?.presentWalletKeys?()
        })
        
        sections[.wallets] = [wallets, showKeys]
        
        if showSeedIsAllow {
            let showSeed = SettingsCellItem(
                title: localize("SETTINGS_SCREEN_SHOW_SEED_TITLE"),
                action: { [weak self] in
                    self?.presentWalletSeed?()
            })
            
            sections[.wallets]?.append(showSeed)
        }
        
        sections[.wallets]?.append(currencyPicker)
        sections[.wallets]?.append(feePriorityPicker)
        
//        let supportUs = SettingsCellItem(
//            title: "Please donate to support us!",
//            action:  { [weak self] in
//                self?.presentDonation?()
//        })
//
//        sections[.donation] = [supportUs]
        sections[.advanced] = [nodeSettings]
        
        let website = "https://havenprotocol.com/"
        let telegram = "https://t.me/Haven_Protocol"
        let discord = "https://discord.gg/vWQ2GZX"
        let twitter = "HavenProtocol"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.lineSpacing = 5
        let attributes = [
            NSAttributedStringKey.font : UIFont.avenirNextMedium(size: 15),
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        let attributedString = NSMutableAttributedString(string: "Website: \(website)\nTelegram: \(telegram)\nDiscord: \(discord)\nTwitter: @\(twitter)", attributes: attributes)
        
        let websiteAddressRange = attributedString.mutableString.range(of: website)
        attributedString.addAttribute(.link, value: website, range: websiteAddressRange)
        
        let telegramAddressRange = attributedString.mutableString.range(of: telegram)
        attributedString.addAttribute(.link, value: telegram, range: telegramAddressRange)
        
        let discordAddressRange = attributedString.mutableString.range(of: discord)
        attributedString.addAttribute(.link, value: discord, range: discordAddressRange)
        
        let twitterAddressRange = attributedString.mutableString.range(of: "@\(twitter)")
        attributedString.addAttribute(.link, value: "https://twitter.com/\(twitter)", range: twitterAddressRange)
        
        sections[.contactUs] = [SettingsTextViewCellItem(attributedString: attributedString)]
        
        let prviacyPolicy = SettingsCellItem(
            title: localize("SETTINGS_SCREEN_PRIVACY_POLICY_TITLE"),
            action: { [weak self] in
                let safariViewController = SFSafariViewController(url: URL(string: "https://havenwallet.com/#/ios-privacy-policy")!)
                self?.present(safariViewController, animated: true)
        })
        
        sections[.other] = [prviacyPolicy]
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let section = SettingsSections(rawValue: section),
            let count = sections[section]?.count else {
                return 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            let item = sections[section]?[indexPath.row] else {
                return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        cell.textLabel?.font = UIFont.avenirNextMedium(size: 15)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            section != .contactUs else {
            return 130
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard let section = SettingsSections(rawValue: section) else {
//            return 0
//        }
        
//        if section != .donation {
//            return 50
//        } else {
//            return 0
//        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSections(rawValue: section) else {
            return nil
        }
        
        let view = UIView(frame:
            CGRect(
                origin: .zero,
                size: CGSize(width: tableView.frame.width, height: 50)))
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: view.frame.width - 20, height: view.frame.height)))
        titleLabel.font = UIFont.avenirNextMedium(size: 17)
        view.backgroundColor =  contentView.backgroundColor
        view.addSubview(titleLabel)
        
        switch section {
        case .personal:
            titleLabel.text = localize("SETTINGS_SCREEN_SECTION_PERSONAL")
        case .wallets:
            titleLabel.text = localize("SETTINGS_SCREEN_SECTION_WALLETS")
        case .advanced:
            titleLabel.text = localize("SETTINGS_SCREEN_SECTION_ADVANCED")
        case .contactUs:
            titleLabel.text = localize("SETTINGS_SCREEN_SECTION_CONTACT")
        case .other:
            titleLabel.text = localize("SETTINGS_SCREEN_SECTION_OTHER")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            let item = sections[section]?[indexPath.row] as? SettingsCellItem else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
        }
        
        item.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
