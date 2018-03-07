//
//  MainViewController.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-05.
//  Copyright © 2018 Michelle. All rights reserved.
//

import UIKit

enum RestaurantSort : String {
    case best_match
    case rating
    case review_count
    case distance
}

class MainViewController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var restaurants: [Restaurant] = []
    var currentSearchTerm = "ethiopian"

    override func viewDidLoad() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = [RestaurantSort.best_match.rawValue,
                                                        RestaurantSort.rating.rawValue,
                                                        RestaurantSort.review_count.rawValue,
                                                        RestaurantSort.distance.rawValue]
        searchController.searchBar.delegate = self

        searchController.searchBar.placeholder = "search Restaurant"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
        self.tableView.tableFooterView = UIView()
        searchController.searchBar.text = "ethiopian"
        getSearchResult(searchTerm: "ethiopian")
    }

    func getSearchResult (searchTerm : String, scope: String = RestaurantSort.best_match.rawValue ) {
        currentSearchTerm = searchTerm
        NetworkManager.sharedManager.searchRestaurant(with: searchTerm, sortBy: scope) { [weak self](response) in
            switch response {
            case .success(let restaurantsList):
                self?.restaurants = restaurantsList
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let message):
                print("Error coe returned: ", message)
            case .semanticError(let reason):
                print(reason.hashValue)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        if let cell = cell as? RestaurantTableViewCell {
            cell.restaurant = restaurants[indexPath.row]
        }
        return cell
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let searchTerm = searchController.searchBar.text {
            let scope = searchBar.scopeButtonTitles![selectedScope]
            getSearchResult(searchTerm: searchTerm, scope: scope)
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            if searchTerm == currentSearchTerm {
                return
            }
            let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
            getSearchResult(searchTerm: searchTerm, scope: scope)
        }
    }
}
