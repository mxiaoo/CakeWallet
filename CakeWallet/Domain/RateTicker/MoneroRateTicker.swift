//
//  MoneroRateTicker.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

final class MoneroRateTicker: RateTicker {
    private(set) var rate: Double = 0 {
        didSet {
            emit(rate: rate)
        }
    }
    private var rateRaw: Double = 0
    private var listeners = [RateListener]()
    private let account: CurrencySettingsConfigurable
    private let url = URL(string: "https://tradeogre.com/api/v1/ticker/BTC-XHV")!
    
    init(account: CurrencySettingsConfigurable) {
        self.account = account
        fetchTicker()
    }
    
    func add(listener: @escaping (Currency, Double) -> Void) {
        listeners.append(listener)
        listener(account.currency, rate)
    }
    
    func fetchTicker() {
        let url = self.url
        DispatchQueue.global(qos: .background).async { [weak self] in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let connection = URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    if let error = error {
                        print("[MoneroRateTicker] [connect] \(error)")
                        return
                    }
                    
                    guard
                        let data = data,
                        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let priceString = decoded["price"] as? String,
                        let price = Double(priceString) else {
                            print("[MoneroRateTicker] [connect] \(String(describing: error))")
                            return
                    }
                    
                    DispatchQueue.main.async {
                        self?.setRate(price)
                    }
                } catch let error {
                    print("[MoneroRateTicker] [connect] \(error)")
                }
            }
            
            connection.resume()
        }
    }
    
    private func emit(rate: Double) {
        listeners.forEach { $0(account.currency, rate) }
    }
    
    private func setRate(_ xmrusdRate: Double) {
        rateRaw = xmrusdRate
        
        account.rate()
            .then { currencyRate in
                self.rate = xmrusdRate * currencyRate
            }.catch { error in
                print(error)
        }
    }
}
