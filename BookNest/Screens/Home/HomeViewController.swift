//
//  HomeViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import UIKit
import Alamofire
import AlamofireImage
import SnapKit

class HomeViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to BookNest!"
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        return label
    }()
       
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Newest books for you. Start reading!"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 40
        return sv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let categories = [
        "Popular Fiction",
        "Popular Science",
        "Romance",
        "Fantasy",
        "Self-Help",
        "Business & Money",
        "Health & Wellness",
        "World History",
        "Art & Creativity",
        "Travel & Adventure"
    ]
    
    private var booksByCategory: [String: [Book]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupTitle()
        setupStackView()
        setupActivityIndicator()
    }

    private func setupScrollView() {
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupTitle() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func setupStackView() {
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupCategorySection(for category: String) {
        guard let books = booksByCategory[category], !books.isEmpty else { return }
        let label = UILabel()
        label.text = category
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        
        let seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        seeAllButton.setTitleColor(.systemBlue, for: .normal)
        let index = categories.firstIndex(of: category) ?? 0
        seeAllButton.tag = index
        seeAllButton.addTarget(self, action: #selector(seeAllTapped(_:)), for: .touchUpInside)
        
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .fill
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        container.addArrangedSubview(label)
        container.addArrangedSubview(seeAllButton)

        stackView.addArrangedSubview(container)
        stackView.setCustomSpacing(16, after: container)

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        stackView.addArrangedSubview(scrollView)
        
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.alignment = .leading
        horizontalStack.isLayoutMarginsRelativeArrangement = true
        horizontalStack.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        scrollView.addSubview(horizontalStack)
        
        horizontalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        for book in books {
            let bookStackView = UIStackView()
            bookStackView.axis = .vertical
            bookStackView.spacing = 4
            bookStackView.alignment = .leading
            
            bookStackView.snp.makeConstraints { make in
                make.width.equalTo(130)
            }
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(130)
                make.height.equalTo(200)
            }
            
            if let url = book.volumeInfo.imageLinks?.imageURL {
                imageView.af.setImage(withURL: url)
            }
            
            let titleLabel = UILabel()
            titleLabel.text = book.volumeInfo.title
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            titleLabel.textColor = .label
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .left
            titleLabel.adjustsFontSizeToFitWidth = true
            
            let authorLabel = UILabel()
            authorLabel.text = book.volumeInfo.authors?.joined(separator: ", ")
            authorLabel.font = .systemFont(ofSize: 12, weight: .regular)
            authorLabel.textColor = .secondaryLabel
            authorLabel.numberOfLines = 2
            authorLabel.textAlignment = .left
            authorLabel.adjustsFontSizeToFitWidth = true
            
            bookStackView.addArrangedSubview(imageView)
            bookStackView.addArrangedSubview(titleLabel)
            bookStackView.addArrangedSubview(authorLabel)
            
            let tapGesture = BookTapGestureRecognizer(target: self, action: #selector(bookTapped(_:)))
            tapGesture.book = book
            bookStackView.isUserInteractionEnabled = true
            bookStackView.addGestureRecognizer(tapGesture)
            
            horizontalStack.addArrangedSubview(bookStackView)
        }
    }
    
    private func setupActivityIndicator() {
        self.view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func fetchData() {
        activityIndicator.startAnimating()
        let group = DispatchGroup()
        
        for category in categories {
            group.enter()
            NetworkManager.shared.fetchBooks(subject: category) { books in
                self.booksByCategory[category] = books
                self.setupCategorySection(for: category)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.activityIndicator.stopAnimating()
        }
    }
    
    @objc private func seeAllTapped(_ sender: UIButton) {
        guard sender.tag < categories.count else { return }
        self.navigationController?.pushViewController(ListDetailViewController(title: categories[sender.tag]), animated: true)
    }
    
    @objc private func bookTapped(_ sender: BookTapGestureRecognizer) {
        guard let book = sender.book else { return }
        self.navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
    }
}

private class BookTapGestureRecognizer: UITapGestureRecognizer {
    var book: Book?
}
