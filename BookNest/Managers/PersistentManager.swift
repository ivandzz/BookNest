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
}
