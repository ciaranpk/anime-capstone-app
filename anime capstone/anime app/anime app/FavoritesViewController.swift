import UIKit

final class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var favorites: [Anime] = []
    private let store = FavoritesStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        configureTable()
        loadFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh when returning
        loadFavorites()
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
    }

    private func loadFavorites() {
        store.loadAsync { [weak self] result in
            switch result {
            case .success(let items):
                self?.favorites = items
                self?.tableView.reloadData()
            case .failure:
                self?.favorites = []
                self?.tableView.reloadData()
            }
        }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = favorites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = favorites[indexPath.row]
        let vc = AnimeDetailViewController(anime: item)
        navigationController?.pushViewController(vc, animated: true)
    }

    // Swipe to delete favorite
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let item = favorites[indexPath.row]
        store.remove(item) { [weak self] result in
            switch result {
            case .success(let items):
                self?.favorites = items
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            case .failure:
                break
            }
        }
    }
}
