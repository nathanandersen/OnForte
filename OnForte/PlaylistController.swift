//
//  PlaylistController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP

/**
 The PlaylistController controls the majority of the playlist workflow.
 It has a table view with the songs in the queue, and a playlist control view.
 
 */
class PlaylistController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var tableView: UITableView!
    var playlistStarted = false
    var songs = SongCollection(name: "queueSongs")
    var sortedSongs: [SongDocument] = []
    var playlistControlView: PlaylistControlView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        renderComponents()
        addConstraintsToComponents()
        addNotificationsToGlobalCenter()
    }

    /**
     Clear the PlaylistController for a new playlist.
    */
    func presentNewPlaylist() {
        let paramObj = [playlistId!]
        Meteor.subscribe("queueSongs",params: paramObj)
        sortedSongs = []
        self.updateTable()
        self.addNotificationsToGlobalCenter()
        self.playlistControlView.updatePlaylistInformation()
    }

    /**
     Initialize the playlist control view
     */
    private func renderPlaylistControlView() {
        playlistControlView = PlaylistControlView()
        playlistControlView.setParentPlaylistController(self)
        self.view.addSubview(playlistControlView)
    }

    /**
     Add the constraints to the playlist control view
    */
    private func addConstraintsToPlaylistControlView() {
        playlistControlView.translatesAutoresizingMaskIntoConstraints = false

        let navHeight = centralNavigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        let pcviewleft = NSLayoutConstraint(item: playlistControlView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0)
        pcviewleft.active = true
        pcviewleft.identifier = "PC view leading"
        let pcviewright = NSLayoutConstraint(item: playlistControlView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0)
        pcviewright.active = true
        pcviewright.identifier = "Pc view trailing"

        // ^^^^ these constraints are essential

        let pcviewtop = NSLayoutConstraint(item: playlistControlView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: navHeight)
        pcviewtop.active = true
        pcviewtop.identifier = "Pc view top"
        playlistControlView.updateConstraints()
    }

    /**
     Called when a song was added, to update the table.
    */
    internal func songWasAdded() {
        dispatch_async(dispatch_get_main_queue(), {
            activityIndicator.showComplete("Song added")
            self.updateTable()
        })
    }

    /**
     Add relevant listeners to the notification center
    */
    private func addNotificationsToGlobalCenter() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.displayNextSong), name: "displayNextSong", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.exitPlaylist), name: "leavePlaylist", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.songWasAdded), name: "songWasAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.updateTable), name: "updateTable", object: nil)
    }

    /**
     Initialize all components
    */
    private func renderComponents() {
        renderPlaylistControlView()
        renderTableView()
    }

    /**
     Add the constraints to the components
    */
    private func addConstraintsToComponents() {
        addConstraintsToPlaylistControlView()
        addConstraintsToTableView()
    }

    /**
     Display the invite controller
    */
    func displayInviteController() {
        let vc = InvitationViewController()
        vc.setParentVC(self)
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }

    /**
     Render the table view
    */
    private func renderTableView(){
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        self.view.addSubview(tableView)
        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "songCell")
        tableView.rowHeight = 85.0
        tableView.tableHeaderView = nil
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.sendSubviewToBack(tableView)
    }

    /**
     Add constraints to the table view
    */
    private func addConstraintsToTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let tableViewTop = NSLayoutConstraint(item: tableView,
                                              attribute: .Top,
                                              relatedBy: .Equal,
                                              toItem: playlistControlView,
                                              attribute: .Bottom,
                                              multiplier: 1,
                                              constant: 0)
        tableViewTop.active = true
        tableViewTop.identifier = "Table View Top"

        let tableViewLeft = NSLayoutConstraint(item: tableView,
                                               attribute: .Leading,
                                               relatedBy: .Equal,
                                               toItem: self.view,
                                               attribute: .Leading,
                                               multiplier: 1,
                                               constant: 0)
        tableViewLeft.active = true
        tableViewLeft.identifier = "Table View Leading"

        let tableViewRight = NSLayoutConstraint(item: tableView,
                                                attribute: .Trailing,
                                                relatedBy: .Equal,
                                                toItem: self.view,
                                                attribute: .Trailing,
                                                multiplier: 1,
                                                constant: 0)
        tableViewRight.active = true
        tableViewRight.identifier = "Table view trailing"

        let tableViewBottom = NSLayoutConstraint(item: tableView,
                                                 attribute: .Bottom,
                                                 relatedBy: .Equal,
                                                 toItem: self.view,
                                                 attribute: .Bottom,
                                                 multiplier: 1,
                                                 constant: 0)
        tableViewBottom.active = true
        tableViewBottom.identifier = "table view bottom"

        tableView.updateConstraints()
    }

    /**
     Return the next song, if it exists, pending voting order and Spotify login status.
     
     - returns: (optional) next song
    */
    internal func getNextSong() -> Song? {
        if spotifySession != nil && spotifySession!.isValid() {
            print("User is logged into Spotify. Playing top song.")
            return (sortedSongs.count > 0) ? Song(songDoc: sortedSongs[0]) : nil
        } else {
            print("User is not logged into Spotify. Playing top non-Spotify song.")
            let topSong: Song? = (sortedSongs.count > 0) ? Song(songDoc: sortedSongs[0]) : nil
            if topSong == nil {
                return nil
            }
            if topSong!.service == .Spotify {
                let nonSpotifySongs = sortedSongs.filter({ $0.platform.lowercaseString != "spotify"})

                let alertController = UIAlertController(title: "Spotify Not Authenticated", message: "Please log in to Spotify through the profile in order to play Spotify music.\n\n Playing top non-Spotify song.", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in

                }
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)

                return (nonSpotifySongs.count > 0) ? Song(songDoc: nonSpotifySongs[0]) : nil
            } else {
                return topSong
            }
        }
    }

    /**
     Display the next song
    */
    func displayNextSong() {
        dispatch_async(dispatch_get_main_queue(), {
            activityIndicator.showComplete("")
            // check out this next line
            self.playlistControlView.musicPlayerView.displaySong()

            // COME BACK TO ME

        })
    }

    /*
    func startPlaylist(sender: AnyObject){
        playlistStarted = true
        displayNextSong()
    }*/

    /*
     Functions related to leaving the playlist
     and other segues
     */

    /**
     Called when the leave button is pressed and confirmed.
     Wipe the variables and boot out.
    */
    func leavePlaylist() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            // stop on a background thread
            if isHost {
                self.playlistControlView.musicPlayerView.musicPlayer.stop()
            }
//            print("This is run on the background queue")
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                print("This is run on the main queue, after the previous code in outer block")
//            })
        })
        (self.navigationController! as! CentralNavigationController).leavePlaylist()
        playlistId = ""
        playlistName = ""
        nowPlaying = nil
        isHost = false
        self.songs.clear()
        (self.mm_drawerController.leftDrawerViewController as! PlaylistHistoryViewController).playedSongs.clear()
        Meteor.unsubscribe("queueSongs")
    }

    /**
     Called when a user presses the cancel button.
    */
    func exitPlaylist() {
        if isHost {
            hostExitPlaylist()
        } else {
            guestExitPlaylist()
        }
    }

    /**
     Called when a guest is trying to leave the playlist.
    */
    func guestExitPlaylist() {
        // Create an alert popup
        let alertController = UIAlertController(title: "Leave Playlist", message: "Are you sure you want to leave this playlist?", preferredStyle: .Alert)
        // with options:
        // a 'cancel' action that just does nothing
        alertController.addAction(UIAlertAction(title: "I'll stay", style: .Cancel, handler: nil))

        // an 'end' action that leaves the playlist
        let endAction = UIAlertAction(title: "I'm out", style: .Destructive) {
            (action) in self.leavePlaylist()
        }
        alertController.addAction(endAction)

        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }

    /**
     Called when the host is trying to exit the playlist.
    */
    func hostExitPlaylist() {
        // Create an alert popup
        let alertController = UIAlertController(title: "End Playlist", message: "You're the host, so leaving this playlist will end it for everyone.", preferredStyle: .Alert)
        // with options:
        // a 'cancel' action that just does nothing
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        // an 'end' action that leaves the playlist
        let endAction = UIAlertAction(title: "End", style: .Destructive) {
            (action) in self.leavePlaylist()
        }
        alertController.addAction(endAction)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }

    /*
     TableViewDelegate Protocol Methods
     and other methods related to the table
     */

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedSongs.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("songCell")! as! SongTableViewCell
        cell.selectionStyle = .None

//        let leftButtons: NSMutableArray = NSMutableArray()
//        leftButtons.sw_addUtilityButtonWithColor(Style.yellowColor, icon: UIImage(named: "star"))
//        cell.leftUtilityButtons = leftButtons as [AnyObject]

        cell.loadItem(sortedSongs[indexPath.row]._id,song: sortedSongs[indexPath.row])
        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }

    /**
     Update the playlist display
    */
    func updatePlaylistDisplay() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            if nowPlaying == nil {
                if isHost && self.songs.count >= 1 {
                    self.playlistControlView.showStartMusicPlayer()
                } else {
                    self.playlistControlView.collapseNowPlayingView()
                }
            } else {
                self.playlistControlView.showANowPlayingView()
            }
        })
    }

    /**
     Update the whole page
    */
    func updateTable() {
        self.sortedSongs = self.songs.sortedByScore()
        self.updatePlaylistDisplay()
    }
}
