import UIKit

final class AnimeDetailViewController: UIViewController {

    private let anime: Anime

    // Simple UI built in code so you can use storyboard if you prefer
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let synopsisLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let favoriteButton = UIButton(type: .system)

    init(anime: Anime) {
        self.anime = anime
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(anime:).")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = anime.title
        setupLayout()
        configureContent()
        configureFavoriteButton()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 12

        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0

        synopsisLabel.font = .preferredFont(forTextStyle: .body)
        synopsisLabel.numberOfLines = 0

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(imageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(synopsisLabel)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            imageView.heightAnchor.constraint(equalToConstant: 220)
        ])

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
    }

    private func configureContent() {
        titleLabel.text = anime.title
        synopsisLabel.text = anime.synopsis ?? "No synopsis available."

        if let url = anime.imageURL {
            imageView.load(url: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }

    private func configureFavoriteButton() {
        favoriteButton.setTitle("Add to Favorites", for: .normal)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            favoriteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Add extra bottom inset to scroll so content isn't hidden by the button
        scrollView.contentInset.bottom = 72
        updateFavoriteButtonTitle()
    }

    private func updateFavoriteButtonTitle() {
        let store = FavoritesStore.shared
        let current = (try? store.load()) ?? []
        if current.contains(anime) {
            favoriteButton.setTitle("Remove from Favorites", for: .normal)
        } else {
            favoriteButton.setTitle("Add to Favorites", for: .normal)
        }
    }

    @objc private func toggleFavorite() {
        let store = FavoritesStore.shared
        let current = (try? store.load()) ?? []
        if current.contains(anime) {
            store.remove(anime) { [weak self] _ in
                self?.updateFavoriteButtonTitle()
            }
        } else {
            store.add(anime) { [weak self] _ in
                self?.updateFavoriteButtonTitle()
            }
        }
    }
}
