// Created By : Ritesh Kafle

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel?


    private var imageRequest: DataRequest?


    func configure(with post: Post) {
        usernameLabel.text = post.user?.username ?? "Unknown"
        captionLabel.text = post.caption
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
        if let lat = post.latitude, let lon = post.longitude {
            locationLabel?.text = "\(lat), \(lon)"
            locationLabel?.isHidden = false
        } else {
            locationLabel?.text = ""
            locationLabel?.isHidden = true
        }
        postImageView.image = nil
        imageRequest?.cancel()

        if let url = post.imageFile?.url {
            imageRequest = AF.request(url).responseImage { [weak self] response in
                if let image = response.value {
                    self?.postImageView.image = image
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        imageRequest?.cancel()
        imageRequest = nil
        locationLabel?.text = ""
        locationLabel?.isHidden = true
    }
}

