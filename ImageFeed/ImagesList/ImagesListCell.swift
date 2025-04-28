
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell{
    //MARK: static properties
    static let reuseIdentifier = "ImagesListCell"
    //MARK: @IBOutlet properties
    @IBOutlet weak var dateLabel: UILabel!{
        didSet {
            dateLabel.font = UIFont.systemFont(ofSize: 13)
            dateLabel.textColor = UIColor(named: "YP White")
        }
    }
    @IBOutlet weak var likeButton: UIButton!{
        didSet {
            likeButton.accessibilityIdentifier = "likeButton"
            likeButton.isAccessibilityElement = true
        }
    }
    @IBOutlet weak var cellImage: UIImageView!
    weak var delegate: ImagesListCellDelegate?
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    

    
    
    func configCell(photo: Photo) -> Bool {
        var status = false
        
        setIsLiked(isLiked: photo.isLiked)
        
//        if let date = photo.createdAt {
//            dateLabel.text = DateFormatter.dateFormatter.string(from: date)
//        } else {
//            dateLabel.text = ""
//        }
        
        guard let url = URL(string: photo.thumbImageURL) else { return status }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url,
                              placeholder: UIImage(named: "stub"),
                              options: [.processor(processor)]
        ){ [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                status = true
            case .failure(_):
                cellImage.image = UIImage(named: "stub")
            }
        }
        
        guard let date = photo.createdAt else {
                    print("there is no date provided")
                    return status }
                
        dateLabel.text = DateFormatter.dateFormatter.string(from: date)
        
        return status
    }
    
    func setIsLiked(isLiked: Bool){
        let liked = isLiked ? UIImage(named:"liked") : UIImage(named:"notLiked")
        likeButton.setImage(liked, for: .normal)
    }
    
}
