//
//  DetailsViewController.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-07.
//  Copyright © 2018 Michelle. All rights reserved.
//

import UIKit
import SDWebImage

class DetailsViewController: UIViewController {

    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingReviewlabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!

    var imageRendered = false
    var reviewRendered = false
    var reviews: [Review] = []
    var imageURLArray: [String] = []

    var restaurant : Restaurant!{
        didSet{
            if restaurant.detailImageUrlStrings.count > 0 {
                imageURLArray = restaurant.detailImageUrlStrings
            } else{
                NetworkManager.sharedManager.getRestaurantDetail(with: restaurant) {[weak self](response) in
                    switch response {
                    case .success (let restaurant):
                        self?.imageURLArray = restaurant.detailImageUrlStrings
                        if self?.isCurrentViewShowing() == true {
                            self?.updateReviewImages()
                        }
                    case .failure(let message):
                        print("Error coe returned: ", message)
                    case .semanticError(let reason):
                        print(reason.hashValue)
                    }
                }
            }


            NetworkManager.sharedManager.getRestaurantReviews(with: restaurant) { [weak self](response) in
                switch response {
                case .success(let reviewList):
                    self?.reviews = reviewList
                    if self?.isCurrentViewShowing() == true {
                        self?.updateReviews()
                    }
                case .failure(let message):
                    print("Error coe returned: ", message)
                case .semanticError(let reason):
                    print(reason.hashValue)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        imageCollectionView.isPagingEnabled = true
        reviewTableView.tableHeaderView = headerView
        reviewTableView.tableFooterView = UIView()
        displayContent()
        updateReviewImages()
        updateReviews()
    }

    func displayContent(){
        nameLabel.text = restaurant?.name ?? ""
        if let restaurant = restaurant {
            ratingReviewlabel.text = "Rating: \(restaurant.rating) with \(restaurant.reviewCount) reviews"
        }else{
            ratingReviewlabel.text = ""
        }
        phoneLabel.text = restaurant?.phoneNumber ?? ""
        addressLabel.text = restaurant?.address ?? ""

    }

    func isCurrentViewShowing() -> Bool {
        return self.viewIfLoaded?.window != nil
    }

    func updateReviewImages() {
        if !imageRendered {
            if imageURLArray.count > 0 {
                imageCollectionView.reloadData()
                imageRendered = true
            }
        }
    }

    func updateReviews() {
        if !reviewRendered {
            if reviews.count > 0 {
                reviewTableView.reloadData()
                reviewRendered = true
            }
        }
    }
}

extension DetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return imageURLArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewImage", for: indexPath)
        if let cell = cell as? ReviewImageCollectionViewCell {
            if let imageURL = URL.init(string: imageURLArray[indexPath.row]){
                cell.imageView.sd_setImage(with: imageURL)
                cell.pagingLabel.text = "\(indexPath.row + 1) of \(imageURLArray.count)"
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        return collectionView.bounds.size
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        if let cell = cell as? ReviewTableViewCell {
            cell.review = reviews[indexPath.row]
        }
        return cell
    }
}


