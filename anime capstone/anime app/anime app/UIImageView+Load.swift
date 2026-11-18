import UIKit

extension UIImageView {
    // New: load with target size and optional placeholder to keep layout stable
    func load(url: URL, targetSize: CGSize, placeholder: UIImage? = nil, completion: (() -> Void)? = nil) {
        // Set a fixed-size placeholder immediately to reserve space
        if let placeholder = placeholder {
            self.image = placeholder
        } else {
            // Generate a neutral placeholder of the exact target size
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let img = renderer.image { ctx in
                UIColor.secondarySystemBackground.setFill()
                ctx.fill(CGRect(origin: .zero, size: targetSize))
            }
            self.image = img
        }

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion?() }
                return
            }
            // Resize off the main thread to avoid layout thrash
            let resized = image.resized(to: targetSize)
            DispatchQueue.main.async {
                // Crossfade to reduce visual jump
                UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: {
                    self.image = resized
                }, completion: { _ in
                    completion?()
                })
            }
        }.resume()
    }

    // Backwards-compatible convenience: loads without specifying size
    // Uses the current bounds size if available; otherwise, falls back to 60x60
    func load(url: URL, completion: (() -> Void)? = nil) {
        let size: CGSize
        if self.bounds.size != .zero {
            size = self.bounds.size
        } else {
            size = CGSize(width: 60, height: 60)
        }
        load(url: url, targetSize: size, placeholder: self.image, completion: completion)
    }
}

private extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
