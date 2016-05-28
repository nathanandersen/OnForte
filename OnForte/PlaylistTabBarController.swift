//
//  PlaylistTabBarController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/28/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation


enum PlaylistControllerType {
    case History
    case Search
    case Main
}

class PlaylistTabBarController: UITabBarController {

    @IBOutlet var bottomTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        displayViewController(PlaylistControllerType.Main)
    }

    internal func displayViewController(playlistControllerType: PlaylistControllerType) {
        if playlistControllerType == .History {
            displayHistoryViewController()
        } else if playlistControllerType == .Search {
            displayMusicSearchViewController()
        } else if playlistControllerType == .Main {
            displayPlaylistViewController()
        } else {
            fatalError()
        }
    }

    private func displayHistoryViewController() {
        for i in 0..<self.viewControllers!.count {
            if let _ = self.viewControllers?[i] as? HistoryViewController {
                self.selectedIndex = i
            }
        }
    }

    private func displayMusicSearchViewController() {
        for i in 0..<self.viewControllers!.count {
            if let _ = self.viewControllers?[i] as? MusicSearchViewController {
                self.selectedIndex = i
            }
        }
    }

    private func displayPlaylistViewController() {
        for i in 0..<self.viewControllers!.count {
            if let _ = self.viewControllers?[i] as? PlaylistViewController {
                self.selectedIndex = i
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