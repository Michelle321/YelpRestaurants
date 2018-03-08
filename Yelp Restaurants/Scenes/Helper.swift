//
//  Helper.swift
//  Yelp Restaurants
//
//  Created by Yunjuan Li on 2018-03-08.
//  Copyright © 2018 Michelle. All rights reserved.
//

import UIKit

struct Helper {
    static func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
}
