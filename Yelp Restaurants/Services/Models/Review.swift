//
//  review.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-05.
//  Copyright © 2018 Michelle. All rights reserved.
//

import Foundation

struct Review {
    let id: String
    let name: String
    let profileImageUrlString: String
    let review: String
    let rating: Float

    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let rating = json["rating"] as? Float,
            let review = json["text"] as? String,
            let user = json["user"] as? [String: String],
            let name = user["name"],
            let imageUrl = user["image_url"]
            else {
                return nil
        }

        self.id = id
        self.name = name
        self.profileImageUrlString = imageUrl
        self.rating = rating
        self.review = review
    }
}

class ReviewList {
    var list: [Review] = []

    init(json: [String: Any]) {
        if let jsonArray = json["reviews"] as? [[String:Any]] {
            for item in jsonArray {
                if let review = Review.init(json: item) {
                    self.list.append(review)
                }
            }
        }
    }
}

