//
//  Localize.swift
//  CakeWallet
//
//  Copyright © 2018 Mykola Misiura. All rights reserved.
//

import Foundation

public func localize(_ key: String) -> String {
    return localize(key, tableName: nil)
}

public func localize(_ key: String, tableName: String?, comment: String = "") -> String {
    return NSLocalizedString(key, tableName: tableName, value: key, comment: comment)
}

public func localize(_ key: String, _ args: CVarArg...) -> String {
    if args.count == 0 {
        return NSLocalizedString(key, value: key, comment: "")
    }
    
    return withVaList(args) { (pointer: CVaListPointer) -> String in
        return NSString(format: localize(key), arguments: pointer) as String
    }
}
