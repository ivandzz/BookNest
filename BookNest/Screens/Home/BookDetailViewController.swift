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
    
    private lazy var pagesReadTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Pages Read"
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(pagesReadChanged), for: .editingChanged)
        return tf
    }()

    private let totalPagesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var pagesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
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
        
        if isSaved {
            loadPagesRead()
        }
        
        setupKeyboardObservers()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.title = book.volumeInfo.title
        
        setupScrollView()
        setupImageView()
        setupTextInfo()
        setupKeyboardToolbar()
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
        
        if let totalPages = book.volumeInfo.pageCount {
            if isSaved {
                totalPagesLabel.text = "/ \(totalPages)"
            } else {
                totalPagesLabel.text = "\(totalPages) pages"
            }
            
            pagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if isSaved {
                pagesStackView.addArrangedSubview(pagesReadTextField)
            }
            
            pagesStackView.addArrangedSubview(totalPagesLabel)
            contentView.addSubview(pagesStackView)
            
            pagesStackView.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview().inset(16)
            }
            
            lastView = pagesStackView
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
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexSpace, doneButton]
        toolbar.sizeToFit()
        
        pagesReadTextField.inputAccessoryView = toolbar
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func loadPagesRead() {
        guard let savedBook = PersistentManager.shared.getSavedBook(by: book.id) else { return }
        pagesReadTextField.text = "\(savedBook.pagesRead)"
    }

    @objc private func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        if isSaved {
            PersistentManager.shared.deleteBook(by: book.id)
            isSaved = false
        } else {
            PersistentManager.shared.saveBook(book)
            isSaved = true
        }
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        setupImageView()
        setupTextInfo()
        
        if isSaved {
            loadPagesRead()
        }
    }
    
    @objc private func pagesReadChanged() {
        guard let text = pagesReadTextField.text,
              let value = Int(text) else { return }
        
        PersistentManager.shared.updatePagesRead(for: book.id, pagesRead: value)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
}
