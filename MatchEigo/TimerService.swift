//
//  TimerService.swift
//  MatchEigo
//
//  Created by Dee Jordan on 17/5/2025.
//
import Foundation
import RealmSwift

class TimerService {
    static let shared = TimerService()
    private var startTime: Date?
    private var realm: Realm
    
    private init() {
        realm = try! Realm()
    }
    
    func startRound() {
        startTime = Date()
    }
    
    func endRound() -> Double {
        guard let start = startTime else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        saveRoundTime(seconds: elapsed)
        return elapsed
    }
    
    private func saveRoundTime(seconds: Double) {
        let roundTime = RoundTime(totalSeconds: seconds)
        
        try! realm.write {
            realm.add(roundTime)
        }
    }
    
    func getRecentTimes() -> Results<RoundTime> {
           return realm.objects(RoundTime.self)
               .sorted(byKeyPath: "date", ascending: false)
       }
       
       func getBestTime() -> Double? {
           return realm.objects(RoundTime.self)
               .min(ofProperty: "totalSeconds") as Double?
       }
   }
