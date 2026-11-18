import UIKit

final class AnimeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var anime: [Anime] = []
    private let api = AnimeAPI.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Anime"

        configureTable()
        loadData()
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FallbackCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnimeCell")
        
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = 80
    }

    private func loadData() {
        // Set useMock = false to hit the real endpoint
        api.fetchAnimeList(useMock: true) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.anime = items
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.presentError(error)
                }
            }
        }
    }

    private func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AnimeListViewController: UITableViewDataSource, UITableViewDelegate {
    // Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anime.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = anime[indexPath.row]

        // Ensure a Subtitle cell style even if no prototype is set
        let reuse = "AnimeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuse)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.synopsis

        // Thumbnail image on the left (stable size)
        let thumbSize = CGSize(width: 60, height: 60)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        if let url = item.imageURL {
            print("Thumb URL:", url.absoluteString)
            cell.imageView?.load(url: url, targetSize: thumbSize)
        } else {
            print("No image URL for:", item.title)
            let renderer = UIGraphicsImageRenderer(size: thumbSize)
            cell.imageView?.image = renderer.image { ctx in
                UIColor.secondarySystemBackground.setFill()
                ctx.fill(CGRect(origin: .zero, size: thumbSize))
            }
        }

        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 2
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = anime[indexPath.row]
        // If you use storyboard segue, set identifier "ShowDetail" and call performSegue.
        // Or push programmatically:
        let vc = AnimeDetailViewController(anime: item)
        navigationController?.pushViewController(vc, animated: true)
    }
}

