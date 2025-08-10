//
//  PersistentManager.swift
//  BookNest
//
//  Created by Іван Джулинський on 09.08.2025.
//

import RealmSwift
import Alamofire
import UIKit

final class PersistentManager {
    
    static let shared = PersistentManager()
    
    private init() { }
    
    func saveBook(_ book: Book) {
        do {
            let savedBook = SavedBook(from: book)
            
            let realm = try Realm()
            try realm.write {
                realm.add(savedBook, update: .modified)
            }
        } catch {
            print("Error saving book: \(error.localizedDescription)")
        }
    }
    
    func deleteBook(by id: String) {
        do {
            let realm = try Realm()
            if let bookToDelete = realm.object(ofType: SavedBook.self, forPrimaryKey: id) {
                try realm.write {
                    realm.delete(bookToDelete)
                }
            }
        } catch {
            print("Error deleting book: \(error.localizedDescription)")
        }
    }
    
    func isBookSaved(id: String) -> Bool {
        do {
            let realm = try Realm()
            return realm.object(ofType: SavedBook.self, forPrimaryKey: id) != nil
        } catch {
            print("Error checking book existence: \(error.localizedDescription)")
            return false
        }
    }
    
    func updatePagesRead(for id: String, pagesRead: Int) {
        do {
            let realm = try Realm()
            
            if let savedBook = realm.object(ofType: SavedBook.self, forPrimaryKey: id) {
                try realm.write {
                    savedBook.pagesRead = pagesRead
                    
                    updateStreak(realm: realm)
                }
            }
        } catch {
            print("Error updating pages read: \(error.localizedDescription)")
        }
    }
    
    func getSavedBook(by id: String) -> SavedBook? {
        do {
            let realm = try Realm()
            return realm.object(ofType: SavedBook.self, forPrimaryKey: id)
        } catch {
            print("Error fetching saved book: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func updateStreak(realm: Realm) {
        let today = Calendar.current.startOfDay(for: Date())
        
        let stats = realm.object(ofType: ReadingStats.self, forPrimaryKey: "global") ?? ReadingStats()
        
        if let lastRead = stats.lastReadDate {
            let lastDay = Calendar.current.startOfDay(for: lastRead)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            switch diff {
            case 0:
                break
            case 1:
                stats.currentStreak += 1
            default:
                stats.currentStreak = 0
            }
        } else {
            stats.currentStreak = 1
        }
        
        stats.lastReadDate = today
        stats.maxStreak = max(stats.maxStreak, stats.currentStreak)
        
        realm.add(stats, update: .modified)
    }
    
    func getReadingStats() -> ReadingStats? {
        do {
            let realm = try Realm()
            return realm.object(ofType: ReadingStats.self, forPrimaryKey: "global")
        } catch {
            print("Error fetching reading stats: \(error.localizedDescription)")
            return nil
        }
    }
    
    func resetStreakIfNeeded() {
        do {
            let realm = try Realm()
            let today = Calendar.current.startOfDay(for: Date())
            
            guard let stats = realm.object(ofType: ReadingStats.self, forPrimaryKey: "global") else {
                let newStats = ReadingStats()
                newStats.id = "global"
                newStats.currentStreak = 0
                newStats.maxStreak = 0
                newStats.lastReadDate = nil
                
                try realm.write {
                    realm.add(newStats)
                }
                return
            }
            
            if let lastRead = stats.lastReadDate {
                let lastDay = Calendar.current.startOfDay(for: lastRead)
                let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
                
                if diff > 1 && stats.currentStreak != 0 {
                    try realm.write {
                        stats.currentStreak = 0
                    }
                }
            } else {
                try realm.write {
                    stats.currentStreak = 0
                }
            }
            
        } catch {
            print("Error resetting streak if needed: \(error.localizedDescription)")
        }
    }
}
