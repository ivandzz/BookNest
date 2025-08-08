//
//  BooksResponse.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import Foundation

struct BooksResponse: Decodable {
    let results: Results
}

struct Results: Decodable {
    let lists: [BookList]
}

struct BookList: Decodable, Equatable {
    let display_name: String
    let books: [Book]
}

struct Book: Decodable, Equatable {
    let author: String
    let book_image: String
    let description: String
    let title: String
}
