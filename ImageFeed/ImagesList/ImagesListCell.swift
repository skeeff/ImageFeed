//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Федор Чистовский on 13.02.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell{
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
}
