//
//  ListDetailViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import UIKit

class ListDetailViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BookCell.self, forCellReuseIdentifier: "BookCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
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

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
}
