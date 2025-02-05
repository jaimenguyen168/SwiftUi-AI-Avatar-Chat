//
//  Dict+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/5/25.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self
            .map({ (key: $0, value: $1) })
            .sortedByKeyPath(keyPath: \.key)
    }
}
