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
        let query: String

        switch subject {
        case "Popular Fiction":
            query = "subject:Fiction AND (bestseller OR popular OR novel)"
        case "Popular Science":
            query = "subject:Science AND (recent OR popular OR modern)"
        case "Romance":
            query = "subject:Romance AND (love OR relationships OR contemporary)"
        case "Fantasy":
            query = "subject:Fantasy AND (magic OR epic OR adventure OR dragon OR sword OR kingdom OR wizard OR prophecy OR elf OR witch OR myth OR)"
        case "Self-Help":
            query = "subject:Self-Help AND (personal OR growth OR habits)"
        case "Business & Money":
            query = "subject:Business AND (startup OR investing OR management)"
        case "Health & Wellness":
            query = "subject:Health AND (fitness OR mental OR diet)"
        case "World History":
            query = "subject:History AND (modern OR biography OR events)"
        case "Art & Creativity":
            query = "subject:Art AND (design OR creativity OR drawing)"
        case "Travel & Adventure":
            query = "subject:Travel AND (guide OR adventure OR destinations)"
        default:
            query = "subject:\(subject)"
        }
        
        let parameters: [String: Any] = [
            "q": query,
            "startIndex": startIndex,
            "maxResults": maxResults,
            "orderBy": "newest",
            "langRestrict": "en",
            "printType": "books"
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
