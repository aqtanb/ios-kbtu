import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!

    private let favorites = Favorite.all
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let first = favorites.indices.first {
            show(at: first, animated: false)
        }
    }

    @IBAction func spinTapped(_ sender: UIButton) {
        guard let next = favorites.indices.filter({ $0 != currentIndex }).randomElement() else { return }
        show(at: next, animated: true)
    }

    private func show(at index: Int, animated: Bool) {
        currentIndex = index
        let favorite = favorites[index]
        let update = {
            self.rankLabel.text = "#\(favorite.rank) of \(self.favorites.count)"
            self.imageView.image = UIImage(named: favorite.imageName)
            self.titleLabel.text = favorite.title
            self.descriptionLabel.text = favorite.description
        }
        guard animated else { return update() }
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: update)
    }
}
