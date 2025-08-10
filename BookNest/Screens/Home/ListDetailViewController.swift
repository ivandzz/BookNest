//
//  ListDetailViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import UIKit
import SnapKit

class ListDetailViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let subject: String
    var books: [Book] = []
    var isLoading = false {
        didSet {
            if isLoading { activityIndicator.startAnimating() }
            else { activityIndicator.stopAnimating() }
        }
    }
    var startIndex = 0
    let maxResults = 20
    
    init(title: String) {
        self.subject = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.title = subject
        
        self.view.addSubview(tableView)
        self.view.addSubview(activityIndicator)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
    }
    
    private func loadBooks() {
        guard !isLoading else { return }
        isLoading = true
        NetworkManager.shared.fetchBooks(subject: subject, startIndex: startIndex, maxResults: maxResults) { newBooks in
            self.books += newBooks
            self.startIndex += self.maxResults
            self.isLoading = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ListDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.identifier, for: indexPath) as? BookCell else {
            return UITableViewCell()
        }
        
        let book = books[indexPath.row]
        cell.configure(with: book)
        return cell
    }
}

extension ListDetailViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height * 4 {
            loadBooks()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedBook = books[indexPath.row]

        let detailVC = BookDetailViewController(book: selectedBook)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
