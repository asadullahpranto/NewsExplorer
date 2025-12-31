import UIKit
import RxSwift

final class HomeTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        // Optimization: Shadow path improves scrolling performance
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let articleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let dateIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private let readMoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Read the article"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()

    private let arrowIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemBlue
        iv.preferredSymbolConfiguration = .init(pointSize: 10, weight: .bold)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private var cellDisposeBag = DisposeBag()
    private var currentImageURL: String?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        cellDisposeBag = DisposeBag()
        currentImageURL = nil
        articleImageView.image = UIImage(resource: .placeholder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Manually setting the shadow path prevents expensive off-screen rendering
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16).cgPath
    }
    
    // MARK: - Configuration
    func configure(with article: Article) {
        sourceLabel.text = article.source.name.uppercased()
        titleLabel.text = article.title
        descriptionLabel.text = article.description

        dateLabel.text = article.publishedAt.toRelativeTime()
        
        descriptionLabel.isHidden = (article.description == nil || article.description?.isEmpty == true)
        
        loadImage(url: article.urlToImage)
    }
    
    private func loadImage(url: String?) {
        guard let urlString = url else {
            articleImageView.image = UIImage(resource: .placeholder)
            return
        }
        
        // Set the current URL to track this specific cell's request
        currentImageURL = urlString
        
        ImageLoader.shared.loadImage(from: urlString)
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                
                guard self.currentImageURL == urlString else { return }
                
                if let image = image {
                    self.setImageWithFade(image)
                } else {
                    self.articleImageView.image = UIImage(resource: .placeholder)
                }
            })
            .disposed(by: cellDisposeBag) // Automatic cancellation on reuse
    }
    
    private func setImageWithFade(_ image: UIImage?) {
        articleImageView.image = image
        articleImageView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.articleImageView.alpha = 1
        }
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(articleImageView)
        
        // 1. Create the Date Side (Icon + Label)
        let dateStack = UIStackView(arrangedSubviews: [dateIcon, dateLabel])
        dateStack.axis = .horizontal
        dateStack.spacing = 4
        dateStack.alignment = .center
        
        // 2. Create the "Button" Side (Label + Arrow)
        let actionStack = UIStackView(arrangedSubviews: [readMoreLabel, arrowIcon])
        actionStack.axis = .horizontal
        actionStack.spacing = 4
        actionStack.alignment = .center
        
        // 3. Create the Footer (Date on Left, Button on Right)
        let footerStack = UIStackView(arrangedSubviews: [dateStack, UIView(), actionStack])
        footerStack.axis = .horizontal
        footerStack.alignment = .center
        // The UIView() in the middle acts as a flexible spacer
        // to push the date to the left and action to the right.
        
        // 4. Main Content Stack
        let mainTextStack = UIStackView(arrangedSubviews: [
            sourceLabel,
            titleLabel,
            descriptionLabel,
            footerStack // Added the footer here
        ])
        mainTextStack.axis = .vertical
        mainTextStack.spacing = 8
        mainTextStack.setCustomSpacing(16, after: descriptionLabel) // Professional gap
        mainTextStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainTextStack)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
            
            articleImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            articleImageView.heightAnchor.constraint(equalTo: articleImageView.widthAnchor, multiplier: 0.56), // 16:9 Aspect Ratio
            
            dateIcon.widthAnchor.constraint(equalToConstant: 12),
            dateIcon.heightAnchor.constraint(equalToConstant: 12),
            
            arrowIcon.widthAnchor.constraint(equalToConstant: 10),
            
            mainTextStack.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: 16),
            mainTextStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainTextStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainTextStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
}
