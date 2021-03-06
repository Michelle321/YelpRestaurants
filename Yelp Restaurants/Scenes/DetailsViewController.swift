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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingReviewlabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var headerView: UIView!
    
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

        tableViewHeight.constant = self.view.frame.height

        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        imageCollectionView.isPagingEnabled = true
        reviewTableView.tableHeaderView = headerView
        reviewTableView.tableFooterView = UIView()
        displayContent()
        updateReviewImages()
        updateReviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.scrollsToTop = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Helper.setStatusBarBackgroundColor(color: UIColor.clear)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
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

extension DetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.imageCollectionView {
            return
        }
        
        let offset = scrollView.contentOffset.y
        
        if offset <= 0 {
            var headerTransform = CATransform3DIdentity
            let headerScaleFactor:CGFloat = -(offset) / imageCollectionView.bounds.height
            let headerSizevariation = ((imageCollectionView.bounds.height * (1.0 + headerScaleFactor)) - imageCollectionView.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            if imageCollectionView.visibleCells.count > 0 {
                imageCollectionView.visibleCells[0].layer.transform = headerTransform
            }
            self.view.bringSubview(toFront: self.imageCollectionView)
            
        } else {
            
            self.view.bringSubview(toFront: self.scrollView)
            if offset < self.imageCollectionView.bounds.size.height + 64 {
                shadowView?.alpha = min (1.0, (offset - 64)/self.imageCollectionView.bounds.size.height)
                if offset > self.imageCollectionView.bounds.size.height - 64 {
                    Helper.setStatusBarBackgroundColor(color: UIColor.red)
                    self.navigationController?.navigationBar.backgroundColor = UIColor.red
                }else{
                    Helper.setStatusBarBackgroundColor(color: UIColor.clear)
                    self.navigationController?.navigationBar.backgroundColor = UIColor.clear
                }
            }
        }

        if scrollView == self.scrollView {
            reviewTableView.isScrollEnabled = (scrollView.contentOffset.y >= 250)
        }

        if scrollView == self.reviewTableView {
            reviewTableView.isScrollEnabled = (reviewTableView.contentOffset.y > 0)
        }
    }
}


