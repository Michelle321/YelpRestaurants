//
//  RestaurantTableViewCell.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-06.
//  Copyright © 2018 Michelle. All rights reserved.
//

import UIKit
import SDWebImage

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var Rating: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var address: UILabel!

    var restaurant: Restaurant? = nil {
        didSet{
            name.text = restaurant?.name
            phone.text = restaurant?.phoneNumber
            address.text = restaurant?.address
            if let restaurant = restaurant{
                if let imageUrl = URL.init(string: restaurant.profileImageUrlString){
                    profileImageView.sd_setImage(with: imageUrl)
                }
                Rating.text = "Rating: \(restaurant.rating) with \(restaurant.reviewCount) reviews"
            }
        }
    }
}
