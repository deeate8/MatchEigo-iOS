//
//  Models.swift
//  MatchEigo
//
//  Created by Dee Jordan on 28/3/2025.
//

import Foundation
import RealmSwift

class UserScore: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var username: String = "YOU"
    @Persisted var score: Int = 0
    @Persisted var date: Date = Date()
}
