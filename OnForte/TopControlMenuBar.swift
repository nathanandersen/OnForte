//
//  TopControlMenuBar.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/24/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class TopControlMenuBar: UIView {

    @IBOutlet var historyButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchButton: UIButton!


    @IBAction func historyButtonPressed(sender: AnyObject) {
        // figure out a way to access playlsit controller
        //playlistController.mm_drawerController.openDrawerSide(.Left, animated: true, completion: nil)
    }

    @IBAction func searchButtonPressed(sender: AnyObject) {

//        playlistController.mm_drawerController.openDrawerSide(.Right, animated: true, completion: nil)
    }

}