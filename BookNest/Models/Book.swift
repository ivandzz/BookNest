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
    let id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Decodable {
    let title: String
    let subtitle: String?
    let authors: [String]?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let categories: [String]?
    let imageLinks: ImageLinks?
}

struct ImageLinks: Decodable {
    let smallThumbnail: String?
    let thumbnail: String?
    let small: String?
    let medium: String?
    let large: String?
    let extraLarge: String?
    
    var imageURL: URL? {
        let preferredOrder = [extraLarge, large, medium, small, thumbnail, smallThumbnail]
        
        for link in preferredOrder {
            if var urlString = link {
                urlString = urlString.replacingOccurrences(of: "http://", with: "https://")
                
                if urlString.contains("zoom=") {
                    urlString = urlString.replacingOccurrences(of: "zoom=1", with: "zoom=3")
                    urlString = urlString.replacingOccurrences(of: "zoom=2", with: "zoom=3")
                }
                
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        
        return nil
    }
}
