import UIKit
import AlamofireImage

class BookCell: UITableViewCell {
    
    static let identifier = "BookCell"
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        authorLabel.text = nil
        categoryLabel.text = nil

        bookImageView.image = nil
        bookImageView.af.cancelImageRequest()
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.volumeInfo.title
        authorLabel.text = book.volumeInfo.authors?.joined(separator: ", ")
        categoryLabel.text = book.volumeInfo.categories?.joined(separator: "& ")
        
        if let url = book.volumeInfo.imageLinks?.imageURL {
            DispatchQueue.main.async {
                self.bookImageView.af.setImage(withURL: url)
            }
        }
    }
    
    func configure(with book: SavedBook?) {
        guard let book else { return }
        
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        categoryLabel.text = book.categories.joined(separator: "& ")
        
        if let imageURLString = book.imageURL, let url = URL(string: imageURLString) {
            DispatchQueue.main.async {
                self.bookImageView.af.setImage(withURL: url)
            }
        }
    }
    
    private func setupUI() {
        self.contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(bookImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(categoryLabel)
        textStackView.addArrangedSubview(authorLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            bookImageView.widthAnchor.constraint(equalToConstant: 65),
            bookImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
