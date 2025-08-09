//
//  BookDetailViewController.swift
//  BookNest
//
//  Created by Іван Джулинський on 08.08.2025.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
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

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
        
    private func setupImageView() {
        contentView.addSubview(imageView)
        
        if let url = book.volumeInfo.imageLinks?.imageURL {
            imageView.af.setImage(withURL: url)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -32),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.54)
        ])
    }
    
    private func setupTextInfo() {
        isSaved = PersistentManager.shared.isBookSaved(id: book.id)
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, saveButton])
        titleStack.axis = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center
        titleStack.distribution = .equalCentering
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleStack)
        
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        titleLabel.text = book.volumeInfo.title

        var lastView: UIView = titleStack

        if let subtitle = book.volumeInfo.subtitle {
            subtitleLabel.text = subtitle
            contentView.addSubview(subtitleLabel)

            NSLayoutConstraint.activate([
                subtitleLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 4),
                subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ])

            lastView = subtitleLabel
        }

        if let categories = book.volumeInfo.categories?.joined(separator: "& "),
           let publishedDate = book.volumeInfo.publishedDate {
            let year = String(publishedDate.prefix(4))
            infoLabel.text = "\(categories) \(year)"
            contentView.addSubview(infoLabel)

            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 4),
                infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ])

            lastView = infoLabel
        }

        if let authors = book.volumeInfo.authors, !authors.isEmpty {
            authorLabel.text = "by \(authors.joined(separator: ", "))"
            contentView.addSubview(authorLabel)

            NSLayoutConstraint.activate([
                authorLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 4),
                authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ])

            lastView = authorLabel
        }

        if let description = book.volumeInfo.description {
            descriptionLabel.text = description
            descriptionLabel.numberOfLines = 0
            contentView.addSubview(descriptionLabel)

            NSLayoutConstraint.activate([
                descriptionLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8),
                descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
            ])

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
