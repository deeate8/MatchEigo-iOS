//
//  RoundTime.swift
//  MatchEigo
//
//  Created by Dee Jordan on 17/5/2025.
//

import Foundation
import RealmSwift

class RoundTime: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date = Date()
    @Persisted var totalSeconds: Double  // 5 games
    @Persisted var averagePerGame: Double  // Calculated field
    
    convenience init(totalSeconds: Double) {
        self.init()
        self.totalSeconds = totalSeconds
        self.averagePerGame = totalSeconds / 5.0
    }
}
