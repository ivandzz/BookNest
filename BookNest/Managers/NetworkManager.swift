//
//  NetworkManager.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import Alamofire

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"

    func fetchBooks(subject: String, startIndex: Int = 0, maxResults: Int = 10, completion: @escaping ([Book]) -> Void) {
        let parameters: [String: Any] = [
            "q": "subject:\(subject)",
            "startIndex": startIndex,
            "maxResults": maxResults
        ]

        AF.request(baseURL, parameters: parameters)
            .responseDecodable(of: BooksList.self) { response in
                switch response.result {
                case .success(let booksList):
                    completion(booksList.items)
                case .failure(let error):
                    print("Error fetching books: \(error.localizedDescription)")
                    completion([])
                }
            }
    }
}
