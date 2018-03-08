//
//  NetworkManager.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-05.
//  Copyright © 2018 Michelle. All rights reserved.
//

import Foundation
import AFNetworking

enum ManagerResponse<Entity, SemanticErrorReason> {
    case success(entity: Entity)
    case failure(message: String)
    case semanticError(reason: AllErrorReason)
}

enum AllErrorReason {
    case emptyResults
    case severError
}

class NetworkManager {

    static let sharedManager = NetworkManager()
    private let manager = AFURLSessionManager.init(sessionConfiguration: URLSessionConfiguration.default)
    private let requestSerializer = AFJSONRequestSerializer.init()

    init(){
        manager.responseSerializer = AFJSONResponseSerializer.init()
        requestSerializer.setValue(YelpFusion.headerFieldValue, forHTTPHeaderField: YelpFusion.headerFieldName)
    }

    func searchRestaurant(with term: String, sortBy: String? = nil, completion:@escaping (ManagerResponse<[Restaurant], AllErrorReason>) -> ()) {
        //For the simplicity of the app, I put the location to Toronto
        var urlString = YelpFusion.apiEndPoint + "search?location=toronto&limit=10&term=" + term
        if let sortBy = sortBy {
            urlString = urlString + "&sort_by=" + sortBy
        }
        let searchReq = requestSerializer.request(withMethod: "GET", urlString: urlString, parameters: nil, error: nil)
        let datatask = manager.dataTask(with: searchReq as URLRequest) { (success, responseObj, requestError) in
            if let json = responseObj as? [String: Any] {
                let restaurantList = RestaurantList.init(json: json).list
                if restaurantList.count > 0 {
                     completion(.success(entity: restaurantList))
                }else{
                    completion(.semanticError(reason: .emptyResults))
                }
            }else{
                if let error = requestError {
                    completion(.failure(message: error.localizedDescription))
                }else{
                    completion(.semanticError(reason: .severError))
                }
            }
        }
        datatask.resume()

    }

    func getRestaurantDetail(with restaurant: Restaurant, completion: @escaping (ManagerResponse<Restaurant, AllErrorReason>)->()){
        let urlString = YelpFusion.apiEndPoint + restaurant.id
        let searchReq = requestSerializer.request(withMethod: "GET", urlString: urlString, parameters: nil, error: nil)
        let datatask = manager.dataTask(with: searchReq as URLRequest) { (success, responseObj, requestError) in
            if let json = responseObj as? [String: Any] {
                restaurant.updateImageUrl(with: json)
                completion(ManagerResponse.success(entity: restaurant))
            }else{
                if let error = requestError {
                    completion(.failure(message: error.localizedDescription))
                }else{
                    completion(.semanticError(reason: .severError))
                }
            }
        }
        datatask.resume()
    }

    func getRestaurantReviews(with restaurant: Restaurant, completion: @escaping (ManagerResponse<[Review], AllErrorReason>)->()){
        let urlString = YelpFusion.apiEndPoint + restaurant.id + "/reviews"
        let searchReq = requestSerializer.request(withMethod: "GET", urlString: urlString, parameters: nil, error: nil)
        let datatask = manager.dataTask(with: searchReq as URLRequest) { (success, responseObj, requestError) in
            if let json = responseObj as? [String: Any] {
                let reviewList = ReviewList.init(json: json).list
                if reviewList.count > 0 {
                    completion(.success(entity: reviewList))
                }else{
                    completion(.semanticError(reason: .emptyResults))
                }
            }else{
                if let error = requestError {
                    completion(.failure(message: error.localizedDescription))
                }else{
                    completion(.semanticError(reason: .severError))
                }
            }
        }
        datatask.resume()
    }

}
