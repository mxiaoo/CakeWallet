//
//  getHeight.swift
//  CakeWallet
//
//  Created by Cake Technologies on 21.02.2018.
//  Copyright © 2018 Cake Technologies.
//

import PromiseKit
import SwiftSoup

enum HeightParseError: Error {
    case cannotParseResult
}

func getHeight(from date: Date) -> Promise<UInt64> {
    return Promise { fulfill, reject in
        DispatchQueue.global(qos: .background).async {
            var request = URLRequest(url: URL(string: "https://explorer.havenprotocol.com/api/networkinfo")!)
            request.httpMethod = "GET"
            
            let connection = URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    if let error = error {
                        print("[getHeight] \(error)")
                        reject(HeightParseError.cannotParseResult)
                        return
                    }
                    
                    guard
                        let data = data,
                        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let innerJSON = decoded["data"] as? [String: Any],
                        let currentHeight = innerJSON["height"] as? Int else {
                            print("[getHeight] \(String(describing: error))")
                            return
                    }
                    
                    let now = Date()
                    let span = date.daysUntil(date: now)
                    let blocksPerDay = 720
                    let blockHeightAtDate = currentHeight - (blocksPerDay * span)
                    
                    if blockHeightAtDate < 0 {
                        reject(HeightParseError.cannotParseResult)
                        return
                    }
                    
                    fulfill(UInt64(blockHeightAtDate))
                } catch let error {
                    print("[getHeight] \(error)")
                    reject(HeightParseError.cannotParseResult)
                }
            }
            
            connection.resume()
        }
    }
}

extension Date {
    func daysUntil(date: Date) -> Int {
        let calendar = NSCalendar.current
        
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}

func fetchRate(for currency: Currency, base: Currency) -> Promise<Double> {
    return Promise { fulfill, reject in
        DispatchQueue.global(qos: .utility).async {
            var url =  URLComponents(string: "https://api.fixer.io/latest")!
            url.queryItems = [
                URLQueryItem(name: "base", value: base.symbol),
                URLQueryItem(name: "symbols", value: currency.symbol)
            ]
            var request = URLRequest(url: url.url!)
            request.httpMethod = "GET"
            
            let connection = URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    if let error = error {
                        reject(error)
                        return
                    }
                    
                    if
                        let data = data,
                        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let rates = decoded["rates"] as? [String: Any],
                        let rate = rates[currency.symbol] as? Double {
                        fulfill(rate)
                    } else {
                        fulfill(0)
                    }
                } catch {
                    reject(error)
                }
            }
            
            connection.resume()
        }
        
    }
}

enum Currency: Int {
    case aud, bgn, brl, cad, chf, cny, czk, eur, dkk, gbp, hkd, hrk, huf, idr, ils, inr, isk, jpy, krw, mxn, myr, nok, nzd, php, pln, ron, rub, sek, sgd, thb, `try`, usd, zar, btc
    
    static var all: [Currency] {
        return [.btc]
        //        return [.aud, .bgn, .brl, .cad, .chf, .cny, .czk, .eur, .dkk, .gbp, .hkd, .hrk, .huf, .idr, .ils, .inr, .isk, .jpy, .krw, .mxn, .myr, .nok, .nzd, .php, .pln, .ron, .rub, .sek, .sgd, .thb, .`try`, .usd, .zar, .btc]
    }
    
    var symbol: String {
        switch self {
        case .aud:
            return "AUD"
        case .bgn:
            return "BGN"
        case .brl:
            return "BRL"
        case .cad:
            return "CAD"
        case .chf:
            return "CHF"
        case .cny:
            return "CNY"
        case .czk:
            return "CZK"
        case .eur:
            return "EUR"
        case .dkk:
            return "DKK"
        case .gbp:
            return "GBP"
        case .hkd:
            return "HKD"
        case .hrk:
            return "HRK"
        case .huf:
            return "HUF"
        case .idr:
            return "IDR"
        case .ils:
            return "ILS"
        case .inr:
            return "INR"
        case .isk:
            return "ISK"
        case .jpy:
            return "JPY"
        case .krw:
            return "KRW"
        case .mxn:
            return "MXN"
        case .myr:
            return "MYR"
        case .nok:
            return "NOK"
        case .nzd:
            return "NZD"
        case .php:
            return "PHP"
        case .pln:
            return "PLN"
        case .ron:
            return "RON"
        case .rub:
            return "RUB"
        case .sek:
            return "SEK"
        case .sgd:
            return "SGB"
        case .thb:
            return "THB"
        case .try:
            return "TRY"
        case .usd:
            return "USD"
        case .zar:
            return "ZAR"
        case .btc:
            return "BTC"
        }
    }
}

extension Currency: Stringify {
    func stringify() -> String {
        return symbol
    }
}
