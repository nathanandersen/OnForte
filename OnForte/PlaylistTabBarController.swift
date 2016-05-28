//
//  PlaylistTabBarController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/28/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

class PlaylistTabBarController: UITabBarController {

    @IBOutlet var bottomTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()


        // select the PlaylistViewController as initial
        for i in 0..<self.viewControllers!.count {
            if let _ = self.viewControllers?[i] as? PlaylistViewController {
                self.selectedIndex = i
                break
            }
        }
    }

    internal func presentNewPlaylist() {
        self.viewControllers?.forEach({
            // if loaded, reset both the PVC and HVC
            if let pvc = $0 as? PlaylistViewController {
                if pvc.isViewLoaded() {
                    pvc.presentNewPlaylist()
                }
            } else if let hvc = $0 as? HistoryViewController {
                if hvc.isViewLoaded() {
                    hvc.presentNewPlaylist()
                }
            }
        })
    }

}