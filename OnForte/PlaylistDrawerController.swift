//
//  PlaylistDrawerController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import MMDrawerController

let totalWidth: CGFloat = UIScreen.mainScreen().bounds.width
let leftDrawerOverlap: CGFloat = 60
let rightDrawerOverlap: CGFloat = 0
let closeOpenDrawerKey = "closeOpenDrawer"

class PlaylistDrawerController: MMDrawerController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.openDrawerGestureModeMask = .PanningCenterView
        self.closeDrawerGestureModeMask = .PanningCenterView

        self.setGestureCompletionBlock({(drawerController, gestureRecognizer) in
            if drawerController.openSide == .Right {
                (self.rightDrawerViewController as! MusicSearchViewController).enableSearchBar()
            }
        })

        self.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlockWithParallaxFactor(2))

        self.leftDrawerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("HistoryViewController")
        self.rightDrawerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MusicSearchViewController")
        self.centerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistViewController")

        setMaximumLeftDrawerWidth(totalWidth - leftDrawerOverlap, animated: true, completion: nil)
        self.setMaximumRightDrawerWidth(totalWidth - rightDrawerOverlap, animated: true, completion: nil)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistDrawerController.closeOpenDrawer), name: closeOpenDrawerKey, object: nil)
    }

    @IBAction func settingsButtonDidPress(sender: AnyObject) {
        (navigationController as! NavigationController).pushSettings()
    }
    
/*    internal func closeOpenDrawer() {
        self.closeDrawerAnimated(true, completion: nil)
    }*/

    /*
    // why is this called update?
    internal func updatePlaylistViewController() {
        (self.centerViewController as! PlaylistController).presentNewPlaylist()
        (self.leftDrawerViewController as! PlaylistHistoryViewController).presentNewPlaylist()
    }*/
}
