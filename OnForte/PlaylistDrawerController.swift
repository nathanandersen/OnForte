//
//  PlaylistDrawerController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import MMDrawerController

let totalScreenWidth = UIScreen.mainScreen().bounds.width
let drawerWidth = totalScreenWidth - 60
let drawerHeight = UIScreen.mainScreen().bounds.height

class PlaylistDrawerController: MMDrawerController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.openDrawerGestureModeMask = .PanningCenterView
        self.closeDrawerGestureModeMask = .PanningCenterView
        self.leftDrawerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistHistoryViewController")
        self.rightDrawerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchViewController")
        self.centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistController")

        self.setMaximumLeftDrawerWidth(drawerWidth, animated: true, completion: nil)
        self.setMaximumRightDrawerWidth(totalScreenWidth, animated: true, completion: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistDrawerController.closeOpenDrawer), name: "closeOpenDrawer", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistDrawerController.completeSearch), name: "completeSearch", object: nil)

    }

/*    func completeSearch() {
        (self.rightDrawerViewController as! SearchViewController).clearSearch()
        self.closeDrawerAnimated(true, completion: nil)
    }*/

    func closeOpenDrawer() {
        self.closeDrawerAnimated(true, completion: nil)
    }
}
