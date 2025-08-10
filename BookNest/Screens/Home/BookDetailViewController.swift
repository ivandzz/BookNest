//
//  BookDetailViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import UIKit
import SnapKit

class BookDetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.tintColor = .systemBlue
        return button
    }()
    
    let book: Book
    
    private var isSaved = false {
        didSet {
            updateSaveButtonIcon()
        }
    }
    
    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    init(book: SavedBook?) {
        guard let book else {
            fatalError("SavedBook cannot be nil")
        }
            
        self.book = book.toBook()
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
        self.title = book.volumeInfo.title
        
        setupScrollView()
        setupImageView()
        setupTextInfo()
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
        
    private func setupImageView() {
        contentView.addSubview(imageView)
        
        if let url = book.volumeInfo.imageLinks?.imageURL {
            imageView.af.setImage(withURL: url)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(imageView.snp.width).multipliedBy(1.54)
        }
    }
    
    private func setupTextInfo() {
        isSaved = PersistentManager.shared.isBookSaved(id: book.id)
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, saveButton])
        titleStack.axis = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center
        titleStack.distribution = .equalCentering
        
        saveButton.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        saveButton.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentView.addSubview(titleStack)
        
        titleStack.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.text = book.volumeInfo.title

        var lastView: UIView = titleStack

        if let subtitle = book.volumeInfo.subtitle {
            subtitleLabel.text = subtitle
            contentView.addSubview(subtitleLabel)
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview().inset(16)
            }

            lastView = subtitleLabel
        }

        if let categories = book.volumeInfo.categories?.joined(separator: "& "),
           let publishedDate = book.volumeInfo.publishedDate {
            let year = String(publishedDate.prefix(4))
            infoLabel.text = "\(categories) \(year)"
            contentView.addSubview(infoLabel)
            
            infoLabel.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview().inset(16)
            }

            lastView = infoLabel
        }

        if let authors = book.volumeInfo.authors, !authors.isEmpty {
            authorLabel.text = "by \(authors.joined(separator: ", "))"
            contentView.addSubview(authorLabel)
            
            authorLabel.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview().inset(16)
            }

            lastView = authorLabel
        }

        if let description = book.volumeInfo.description {
            descriptionLabel.text = description
            descriptionLabel.numberOfLines = 0
            contentView.addSubview(descriptionLabel)
            
            descriptionLabel.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).offset(-16)
            }

            lastView = descriptionLabel
        }
    }
    
    private func updateSaveButtonIcon() {
        let imageName = isSaved ? "bookmark.fill" : "bookmark"
        let image = UIImage(systemName: imageName)
        saveButton.setImage(image, for: .normal)
    }
    
    @objc private func saveButtonTapped() {
        if isSaved {
            PersistentManager.shared.deleteBook(by: book.id)
            isSaved = false
        } else {
            PersistentManager.shared.saveBook(book)
            isSaved = true
        }
    }
}
