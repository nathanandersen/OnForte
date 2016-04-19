//
//  PlaylistController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP

class PlaylistController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var tableView: UITableView!
    var playlistStarted = false
    var songs = SongCollection(name: "queueSongs")
    var sortedSongs: [SongDocument]!
    var playlistControlView: PlaylistControlView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.view.frame)
        print("bah")
        activityIndicator.showComplete("")
        self.navigationItem.setHidesBackButton(true, animated:false)
        let paramObj = [playlistId!]
        Meteor.subscribe("queueSongs",params: paramObj)
        sortedSongs = []

        renderComponents()
        addConstraintsToComponents()
        addNotificationsToGlobalCenter()
    }

    func renderPlaylistControlView() {
        playlistControlView = PlaylistControlView()
        playlistControlView.setParentPlaylistController(self)
        print(playlistControlView.playlistController)
        self.view.addSubview(playlistControlView)
    }

    func addConstraintsToPlaylistControlView() {
        playlistControlView.translatesAutoresizingMaskIntoConstraints = false

        let navHeight = centralNavigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height
        let pcviewleft = NSLayoutConstraint(item: playlistControlView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0)
        pcviewleft.active = true
        pcviewleft.identifier = "PC view leading"
        let pcviewright = NSLayoutConstraint(item: playlistControlView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0)
        pcviewright.active = true
        pcviewright.identifier = "Pc view trailing"
        let pcviewtop = NSLayoutConstraint(item: playlistControlView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: navHeight)
        pcviewtop.active = true
        pcviewtop.identifier = "Pc view top"
        playlistControlView.updateConstraints()
    }

    func songWasRemoved() {
        print("ooh")
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTable()
        })
    }

    func songWasAdded() {
        dispatch_async(dispatch_get_main_queue(), {
            print("meh")
            activityIndicator.showComplete("Song added")
            self.updateTable()
        })
    }

    func addNotificationsToGlobalCenter() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.updateTable), name:"load", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.displayNextSong), name: "displayNextSong", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.exitPlaylist), name: "leavePlaylist", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.songWasAdded), name: "songWasAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.songWasRemoved), name: "songWasRemoved", object: nil)
    }

    func renderComponents() {
        renderPlaylistControlView()
        renderTableView()
    }

    func addConstraintsToComponents() {
        addConstraintsToPlaylistControlView()
        addConstraintsToTableView()
    }

    func startSearch() {
        (self.mm_drawerController as! PlaylistDrawerController).openDrawerSide(.Right, animated: true, completion: nil)
    }


    func inviteButtonPressed() {
        let vc = InvitationViewController()
        vc.setParentVC(self)
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }

    func renderTableView(){
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        self.view.addSubview(tableView)
        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "songCell")
        tableView.rowHeight = 85.0
        tableView.tableHeaderView = nil;
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.view.sendSubviewToBack(tableView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.updateTable), name:"load", object: nil)
    }

    func addConstraintsToTableView() {
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
                                               attribute: .Left,
                                               relatedBy: .Equal,
                                               toItem: self.view,
                                               attribute: .Left,
                                               multiplier: 1,
                                               constant: 0)
        tableViewLeft.active = true
        tableViewLeft.identifier = "Table View Left"

        let tableViewRight = NSLayoutConstraint(item: tableView,
                                                attribute: .Right,
                                                relatedBy: .Equal,
                                                toItem: self.view,
                                                attribute: .Right,
                                                multiplier: 1,
                                                constant: 0)
        tableViewRight.active = true
        tableViewRight.identifier = "Table view right"

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

    func getNextSong() -> Song? {
        return (sortedSongs.count > 0) ? Song(songDoc: sortedSongs[0]) : nil
    }

    func displayNextSong() {
        dispatch_async(dispatch_get_main_queue(), {
            activityIndicator.showComplete("")
//            self.nowPlayingView.updateTrackDisplay()
        })
    }

    func startPlaylist(sender: AnyObject){
//        nowPlayingView.playNextSong()
        playlistStarted = true
//        hideStart()
//        showNowPlayingView()
        displayNextSong()
    }

    /*
     Functions related to leaving the playlist
     and other segues
     */
    func leavePlaylist() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND


        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            // stop on a background thread
//            if isHost {
//                self.nowPlayingView.stop()
//            }
            print("This is run on the background queue")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
            })
        })

        self.navigationController!.popToRootViewControllerAnimated(true)
        playlistId = ""
        playlistName = ""
        nowPlaying = nil
        isHost = false
//        self.songs = SongCollection(name: "songs")
        self.songs = SongCollection(name: "queueSongs")
        (self.mm_drawerController.leftDrawerViewController as! PlaylistHistoryViewController).playedSongs = PlaylistSongHistory(name: "playedSongs")
        Meteor.unsubscribe("songs")
    }

    func exitPlaylist() {
        if isHost {
            hostExitPlaylist()
        } else {
            guestExitPlaylist()
        }
    }

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

        self.presentViewController(alertController, animated: true, completion: nil)
    }

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

        self.presentViewController(alertController, animated: true, completion: nil)
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

        let leftButtons: NSMutableArray = NSMutableArray()
        leftButtons.sw_addUtilityButtonWithColor(Style.yellowColor, icon: UIImage(named: "star"))
        cell.leftUtilityButtons = leftButtons as [AnyObject]

        cell.loadItem(sortedSongs[indexPath.row]._id,song: sortedSongs[indexPath.row])

        // I have some doubts about this ^

        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }

    func updateTable() {

        sortedSongs = songs.sortedByScore()
        self.tableView.reloadData()

        if nowPlaying == nil {
            if isHost && songs.count >= 1 {
                playlistControlView.showStartMusicPlayer()
            } else {

                playlistControlView.collapseNowPlayingView()
            }
        } else {
            playlistControlView.showANowPlayingView()
        }
    }


}
