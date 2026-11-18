import UIKit

final class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinner:  UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!

    private var results: [Anime] = []
    private let api = AnimeAPI.shared
    private var debounceWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        configureUI()
        emptyLabel.isHidden = true
        spinner.hidesWhenStopped = true
    }

    private func configureUI() {
        tableView.dataSource = self
        tableView.delegate = self

        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.placeholder = "Search anime titles"
    }

    private func performSearch(query: String) {
        print("Performing search for:", query)
        emptyLabel.isHidden = true
        spinner.startAnimating()
        if query.lowercased() == "mock" {
            self.results = [
                Anime(id: 1000, title: "Naruto (Mock)", synopsis: "Mocked result", imageURL: nil),
                Anime(id: 1001, title: "One Piece (Mock)", synopsis: "Mocked result", imageURL: nil)
            ]
            self.tableView.reloadData()
            spinner.stopAnimating()
            emptyLabel.isHidden = !(results.isEmpty)
            return
        }
        api.searchAnime(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.results = items
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                    self?.emptyLabel.isHidden = !(items.isEmpty)
                case .failure(let error):
                    print("Search failed:", error.localizedDescription)
                    self?.results = []
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                    self?.emptyLabel.isHidden = false
                    self?.presentSearchError("The request failed or timed out. Please try again, check your connection, or try a different network.")
                }
            }
        }
    }

    private func presentSearchError(_ message: String) {
        let alert = UIAlertController(title: "Search Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = results[indexPath.row]
        let reuse = "ResultCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuse)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.synopsis
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 2
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = results[indexPath.row]
        let vc = AnimeDetailViewController(anime: item)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search text changed:", searchText)
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            debounceWorkItem?.cancel()
            results = []
            tableView.reloadData()
            emptyLabel.isHidden = true
            spinner.stopAnimating()
            return
        }
        // Debounce to avoid spamming the API
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: searchText)
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(query: searchBar.text ?? "")
    }
}
