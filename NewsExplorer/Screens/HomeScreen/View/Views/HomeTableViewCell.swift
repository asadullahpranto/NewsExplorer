//
//  HomeTableViewCell.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import UIKit
import RxSwift

class HomeTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView = UIView()
    let articleImageView = UIImageView()
    private let sourceLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let disposeBag = DisposeBag()
    private var cellDisposeBag = DisposeBag()
    private var currentImageURL: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellDisposeBag = DisposeBag() // 🔥 cancels image request
        currentImageURL = nil
        articleImageView.image = UIImage(resource: .placeholder)
        articleImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Configuration
    func configure(with article: Article) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        
        articleImageView.image = UIImage(resource: .placeholder)
        
        guard let url = article.urlToImage else { return }
        currentImageURL = url
        
        ImageLoader.shared
            .loadImage(from: url)
            .subscribe(onSuccess: { [weak self] image in
                guard let self = self else { return }
                guard self.currentImageURL == url else { return }
                self.setImageWithFade(image)
            })
            .disposed(by: cellDisposeBag) // 🔥 auto-cancel on reuse
    }
    
    private func setImageWithFade(_ image: UIImage?) {
        guard let image = image else { return }
        articleImageView.alpha = 0
        articleImageView.image = image
        
        UIView.animate(withDuration: 0.25) {
            self.articleImageView.alpha = 1
        }
    }
    
    // MARK: - Layout Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // 1. Container View (The Card)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // 2. Article Image
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        articleImageView.layer.cornerRadius = 16
        articleImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
        
        // 3. Source Label
        sourceLabel.font = .systemFont(ofSize: 12, weight: .bold)
        sourceLabel.textColor = .systemBlue
        
        // 4. Title Label
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 2
        
        // 5. Description Label
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 3
        
        let stackView = UIStackView(arrangedSubviews: [
            sourceLabel,
            titleLabel,
            descriptionLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(articleImageView)
        containerView.addSubview(stackView)
        
//        articleImageView.contentMode = .scaleAspectFill
        
        // MARK: - Constraints
        NSLayoutConstraint.activate([
            // Container constraints (create the "card" margins)
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // This makes the card center and stay at a readable width on iPad
            containerView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            
            // Image constraints
            articleImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            articleImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Text Stack constraints
            stackView.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
}
