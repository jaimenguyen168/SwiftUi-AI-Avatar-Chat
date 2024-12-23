//
//  Date+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import Foundation

extension Date {
    func addTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let dayInterval = TimeInterval(days * 24 * 60 * 60)
        let hourInterval = TimeInterval(hours * 60 * 60)
        let minuteInterval = TimeInterval(minutes * 60)
        return self.addingTimeInterval(dayInterval + hourInterval + minuteInterval)
    }
}
