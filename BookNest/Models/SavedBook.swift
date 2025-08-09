//
//  SavedBook.swift
//  BookNest
//
//  Created by Іван Джулинський on 09.08.2025.
//

import Foundation
import RealmSwift

class SavedBook: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var subtitle: String?
    @Persisted var authors: List<String>
    @Persisted var publishedDate: String?
    @Persisted var descriptionText: String?
    @Persisted var pageCount: Int = 0
    @Persisted var categories: List<String>
    @Persisted var imageURL: String?
    
    convenience init(from book: Book) {
        self.init()
        self.id = book.id
        self.title = book.volumeInfo.title
        self.subtitle = book.volumeInfo.subtitle
        self.publishedDate = book.volumeInfo.publishedDate
        self.descriptionText = book.volumeInfo.description
        self.pageCount = book.volumeInfo.pageCount ?? 0
        self.categories.append(objectsIn: book.volumeInfo.categories ?? [])
        self.authors.append(objectsIn: book.volumeInfo.authors ?? [])
        self.imageURL = book.volumeInfo.imageLinks?.imageURL?.absoluteString
    }
    
    func toBook() -> Book {
        let volumeInfo = VolumeInfo(
            title: title,
            subtitle: subtitle,
            authors: authors.isEmpty ? nil : Array(authors),
            publishedDate: publishedDate,
            description: descriptionText,
            pageCount: pageCount,
            categories: categories.isEmpty ? nil : Array(categories),
            imageLinks: ImageLinks(smallThumbnail: nil, thumbnail: nil, small: nil, medium: nil, large: nil, extraLarge: imageURL)
        )
        return Book(id: id, volumeInfo: volumeInfo)
    }
}
