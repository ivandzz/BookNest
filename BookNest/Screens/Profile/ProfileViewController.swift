//
//  ProfileViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 09.08.2025.
//

import UIKit
import RealmSwift

class ProfileViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        label.text = "Your Profile"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let savedBookTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Saved Books"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let savedBooksTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No saved books yet.\nStart adding your favorites!"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var notificationToken: NotificationToken?
    
    private var savedBooks: Results<SavedBook>?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchSavedBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchSavedBooks()
        savedBooksTableView.reloadData()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        setupTitleStack()
        setupSavedBooksLabel()
        setupSavedBooksTableView()
        setupEmptyState()
    }
    
    private func setupTitleStack() {
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, profileImageView])
        titleStack.axis = .horizontal
        titleStack.distribution = .equalSpacing
        titleStack.alignment = .center
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(titleStack)
        
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 13),
            titleStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            titleStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupSavedBooksLabel() {
        self.view.addSubview(savedBookTitleLabel)
        
        NSLayoutConstraint.activate([
            savedBookTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            savedBookTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            savedBookTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24)
        ])
    }
    
    private func setupSavedBooksTableView() {
        self.view.addSubview(savedBooksTableView)
        
        savedBooksTableView.dataSource = self
        savedBooksTableView.delegate = self
        
        NSLayoutConstraint.activate([
            savedBooksTableView.topAnchor.constraint(equalTo: savedBookTitleLabel.bottomAnchor, constant: 20),
            savedBooksTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            savedBooksTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            savedBooksTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        self.view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: savedBooksTableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: savedBooksTableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func fetchSavedBooks() {
        let realm = try! Realm()
        savedBooks = realm.objects(SavedBook.self)
        emptyStateLabel.isHidden = !(savedBooks?.isEmpty ?? true)
        
        notificationToken = savedBooks?.observe { [weak self] changes in
            guard let self else { return }
            
            DispatchQueue.main.async {
                guard self.isViewLoaded && self.view.window != nil else { return }
                
                switch changes {
                case .initial:
                    self.savedBooksTableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    self.savedBooksTableView.performBatchUpdates {
                        self.savedBooksTableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.savedBooksTableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.savedBooksTableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    }
                case .error(let error):
                    print("Realm notification error: \(error)")
                }
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedBooks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.identifier, for: indexPath) as? BookCell else {
            return UITableViewCell()
        }
        
        let book = savedBooks?[indexPath.row]
        cell.configure(with: book)
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedBook = savedBooks?[indexPath.row]

        let detailVC = BookDetailViewController(book: selectedBook)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
