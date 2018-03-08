//
//  ReviewTableViewCell.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-07.
//  Copyright © 2018 Michelle. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var userReview: UILabel!

    var review: Review? = nil{
        didSet{
            userName.text = review?.name
            userReview.text = review?.review
            if let review = review{
                userRating.text = "\(review.rating) Stars"
                if let imageUrl = URL.init(string: review.profileImageUrlString){
                    userProfileImage.sd_setImage(with: imageUrl)
                }
            }
        }
    }
}
