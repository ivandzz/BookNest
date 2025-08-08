//
//  Book.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import Foundation

struct BooksList: Decodable {
    let items: [Book]
}

struct Book: Decodable {
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String
    let subtitle: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let categories: [String]?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Decodable {
    let smallThumbnail: String
    let thumbnail: String
    
    var thumbnailURL: URL? {
        return URL(string: thumbnail.replacingOccurrences(of: "http://", with: "https://"))
    }
}
