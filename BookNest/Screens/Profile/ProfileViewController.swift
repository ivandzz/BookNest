//
//  ProfileViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 09.08.2025.
//

import UIKit
import SnapKit
import RealmSwift

class ProfileViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        label.text = "Your Profile"
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle.fill")
        return imageView
    }()
    
    private let savedBookTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "Saved Books"
        return label
    }()
    
    private let savedBooksTableView: UITableView = {
        let tableView = UITableView()
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
        
        self.view.addSubview(titleStack)
        
        titleStack.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(13)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
    }
    
    private func setupSavedBooksLabel() {
        self.view.addSubview(savedBookTitleLabel)
        
        savedBookTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func setupSavedBooksTableView() {
        self.view.addSubview(savedBooksTableView)
        
        savedBooksTableView.dataSource = self
        savedBooksTableView.delegate = self
        
        savedBooksTableView.snp.makeConstraints { make in
            make.top.equalTo(savedBookTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyState() {
        self.view.addSubview(emptyStateLabel)
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(savedBooksTableView)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func fetchSavedBooks() {
        do {
            let realm = try Realm()
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
        } catch {
            print("Error fetching saved books: \(error)")
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
