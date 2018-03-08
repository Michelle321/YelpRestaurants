//
//  restaurant.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-05.
//  Copyright © 2018 Michelle. All rights reserved.
//

import Foundation

class Restaurant {
    let id: String
    let name: String
    let phoneNumber: String
    let address: String
    let profileImageUrlString: String
    let reviewCount: Int
    let rating: Float
    let distance: Float
    var detailImageUrlStrings: [String] = []

    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let name = json["name"] as? String,
            let imageUrl = json["image_url"] as? String,
            let reviewCount = json["review_count"] as? Int,
            let rating = json["rating"] as? Float,
            let phoneNumber = json["display_phone"] as? String,
            let distance = json["distance"] as? Float,
            let address = json["location"] as? [String: Any],
            let displayAddress = address["display_address"] as? [String]
            else {
                return nil
        }

        self.id = id
        self.name = name
        self.profileImageUrlString = imageUrl
        self.reviewCount = reviewCount
        self.rating = rating
        self.phoneNumber = phoneNumber
        self.distance = distance
        self.address = displayAddress.joined(separator: " ")
    }

    func updateImageUrl(with json: [String: Any]) {
        guard let imageslist = json["photos"] as? [String] else {
            return
        }

        self.detailImageUrlStrings = imageslist
    }
}

class RestaurantList {
    var list: [Restaurant] = []

    init(json: [String: Any]) {
        if let jsonArray = json["businesses"] as? [[String:Any]] {
            for item in jsonArray {
                if let restaurant = Restaurant.init(json: item) {
                    self.list.append(restaurant)
                }
            }
        }
    }
}


