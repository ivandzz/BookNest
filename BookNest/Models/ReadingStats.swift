//
//  ReadingStats.swift
//  BookNest
//
//  Created by Іван Джулинський on 10.08.2025.
//

import Foundation
import RealmSwift

class ReadingStats: Object {
    @Persisted(primaryKey: true) var id: String = "global"
    @Persisted var lastReadDate: Date?
    @Persisted var currentStreak: Int = 0
    @Persisted var maxStreak: Int = 0
}
