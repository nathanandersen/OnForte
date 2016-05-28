//
//  PlaylistTabBarController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/28/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class PlaylistTabBarController: UITabBarController {

    @IBOutlet var bottomTabBar: UITabBar!
/*    override func viewDidLoad() {
        super.viewDidLoad()
    }*/

    internal func presentNewPlaylist() {
        let pvc = self.viewControllers![0] as! PlaylistViewController
        if pvc.isViewLoaded() {
            pvc.presentNewPlaylist()
        }
        let hvc = self.viewControllers![1] as! HistoryViewController
        if hvc.isViewLoaded() {
            hvc.presentNewPlaylist()
        }
//        (self.viewControllers![0] as! PlaylistViewController).presentNewPlaylist()
//        (self.viewControllers![1] as! HistoryViewController).presentNewPlaylist()
    }

}