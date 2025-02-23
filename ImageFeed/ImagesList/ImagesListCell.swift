//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Федор Чистовский on 13.02.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell{
    //MARK: static properties
    static let reuseIdentifier = "ImagesListCell"
    //MARK: @IBOutlet properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
}
