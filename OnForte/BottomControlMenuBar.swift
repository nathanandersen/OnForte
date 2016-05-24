//
//  BottomControlMenuBar.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/24/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class BottomControlMenuBar: UIView {

    @IBOutlet var leaveButton: UIButton!

    @IBOutlet var inviteButton: UIButton!

    @IBOutlet var idLabel: UILabel!
    
    @IBAction func leaveButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("leavePlaylist", object: nil)

        // maybe instead, we can call PlaylistHandler.leavePlaylist
        // or something like that?
    }
    @IBAction func inviteButtonPressed(sender: AnyObject) {
//        playlistController.displayInviteController()
    }
}