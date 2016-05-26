//
//  NavigationController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

/**
 This is a UIViewController that never displays a back button. Simple extension,
 written to pair with the custom NavigationController.
 */
class HiddenBackButtonViewController: UIViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
}

class NavigationController: UINavigationController {
    
}