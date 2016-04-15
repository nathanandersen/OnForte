//
//  PlaylistController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP


//temporary fix

//var timer: NSTimer!


class PlaylistController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var startButton: UIButton!
    var tableView: UITableView!
    var playlistStarted = false
    var songs = SongCollection(name: "queueSongs")
//    var songs = SongCollection(name: "songs")

//    var playedSongs = PlaylistSongHistory(name: "playedSongs")

    var sortedSongs: [SongDocument]!
//    var playlistName: String = ""

    var slideDownView: UIView!
    var playlistNameLabel: UILabel!
    var playlistIdLabel: UILabel!

    var inviteButton: UIButton!

    var addTrackButton: UIButton!
    var nowPlayingView: NowPlayingView!

    var slideDownViewHidden: NSLayoutConstraint!
    var slideDownViewPosition1: NSLayoutConstraint!
    var slideDownViewPosition2: NSLayoutConstraint!

    var addTrackHidden: NSLayoutConstraint!
    var addTrackShown: NSLayoutConstraint!

    var startHidden: NSLayoutConstraint!
    var startShown: NSLayoutConstraint!

    var gestureRecognizerView: UIView!


    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PlaylistController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

        return refreshControl
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.view.frame)

        activityIndicator.showComplete("")

        self.navigationItem.setHidesBackButton(true, animated:false)

        let paramObj = [playlistId!]
        Meteor.subscribe("queueSongs",params: paramObj)
//        Meteor.subscribe("songs",params: paramObj)
//        Meteor.subscribe("playedSongs",params: paramObj)

        sortedSongs = []

        renderComponents()
        addConstraintsToComponents()
        addNotificationsToGlobalCenter()

        // TEMPORARY FIX

//        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(PlaylistController.updateTable), userInfo: nil, repeats: true)
    }

    func songWasRemoved() {
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.enableRefreshControl), name: "enableRefreshControl", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.disableRefreshControl), name: "disableRefreshControl", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.exitPlaylist), name: "leavePlaylist", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.songWasAdded), name: "songWasAdded", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.songWasRemoved), name: "songWasRemoved", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistController.hideListOfPlayedSongs), name: "hidePlayedList", object: nil)
    }

    func renderComponents() {
        renderPlaylistNameLabel()

        renderSlideDownView()
        renderAddTrackButton()
        renderInviteButton()
        renderNowPlayingView()

        if isHost {
            renderStartButton()
        }
        renderTableView()
        renderPlaylistIdLabel()
    }

    func addConstraintsToComponents() {
        addConstraintsToSlideDownView()
        addConstraintsToAddTrackButton()
        if isHost {
            addConstraintsToStartButton()
        }
        addConstraintsToTableView()
        addConstraintsToPlaylistNameLabel()
        addConstraintsToInviteButton()
        addConstraintsToNowPlayingView()
        addConstraintsToPlaylistIdLabel()
        self.view.sendSubviewToBack(tableView)
        // just to be safe ^
    }

    func enableRefreshControl() {
        self.tableView.addSubview(self.refreshControl)
    }

    func disableRefreshControl() {
        self.refreshControl.removeFromSuperview()
    }

    func renderAddTrackButton() {
        addTrackButton = Style.circularButton(30.0)
        addTrackButton.setTitle("+", forState: .Normal)
        addTrackButton.addTarget(self, action: #selector(PlaylistController.startSearch), forControlEvents: .TouchUpInside)
        self.view.addSubview(addTrackButton)
    }

    func addConstraintsToAddTrackButton() {
        addTrackButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: addTrackButton,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: tableView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -10).active = true

        addTrackShown = NSLayoutConstraint(item: addTrackButton,
                                           attribute: .Right,
                                           relatedBy: .Equal,
                                           toItem: self.view,
                                           attribute: .Right,
                                           multiplier: 1,
                                           constant: -10)
        addTrackShown.active = true

        addTrackHidden = NSLayoutConstraint(item: addTrackButton,
                                            attribute: .Right,
                                            relatedBy: .Equal,
                                            toItem: self.view,
                                            attribute: .Right,
                                            multiplier: 1,
                                            constant: 50)
        addTrackHidden.active = false

        NSLayoutConstraint(item: addTrackButton,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 50).active = true

        NSLayoutConstraint(item: addTrackButton,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 50).active = true

        addTrackButton.updateConstraints()
    }

    func showAddTrack() {
        self.addTrackHidden.active = false
        UIView.animateWithDuration(0.15, animations: {
            self.addTrackShown.active = true
            self.addTrackButton.layoutIfNeeded()
        })
    }

    func hideAddTrack() {
        self.addTrackShown.active = false
        UIView.animateWithDuration(0.15, animations: {
            self.addTrackHidden.active = true
            self.addTrackButton.layoutIfNeeded()
        })
    }

    func startSearch() {
        self.mm_drawerController.openDrawerSide(.Right, animated: true, completion: nil)
    }

    func renderSlideDownView(){
        slideDownView = UIView()
        slideDownView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
        self.view.addSubview(slideDownView)
        self.view.sendSubviewToBack(slideDownView)
    }

    func addConstraintsToSlideDownView(){
        slideDownView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: slideDownView,
                           attribute: .Right,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Right,
                           multiplier: 1,
                           constant: 0.0).active = true

        NSLayoutConstraint(item: slideDownView,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Left,
                           multiplier: 1,
                           constant: 0.0).active = true


//        let navHeight = centralNavigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height

        let navHeight = centralNavigationController.navigationBar.frame.maxY

        NSLayoutConstraint(item: slideDownView,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Top,
                           multiplier: 1,
                           constant: 0.0).active = true

        slideDownViewHidden = NSLayoutConstraint(item: slideDownView,
                                                 attribute: .Bottom,
                                                 relatedBy: .Equal,
                                                 toItem: self.view,
                                                 attribute: .Top,
                                                 multiplier: 1,
                                                 constant: 0)
        slideDownViewHidden.active = false


        slideDownViewPosition1 = NSLayoutConstraint(item: slideDownView,
                                                    attribute: .Bottom,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .Top,
                                                    multiplier: 1,
                                                    constant: navHeight + 40)
        slideDownViewPosition1.active = true

        slideDownViewPosition2 = NSLayoutConstraint(item: slideDownView,
                                                    attribute: .Bottom,
                                                    relatedBy: .Equal,
                                                    toItem: self.view,
                                                    attribute: .Top,
                                                    multiplier: 1,
                                                    constant: navHeight + 125)
        slideDownViewPosition2.active = false

        slideDownView.setNeedsLayout()
    }

    func renderInviteButton() {
        inviteButton = Style.iconButton()
        inviteButton.setImage(UIImage(named: "invite")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        inviteButton.imageEdgeInsets = UIEdgeInsetsMake(5, 3, 5, 3)
        inviteButton.addTarget(self, action: #selector(PlaylistController.inviteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        slideDownView.addSubview(inviteButton)
    }

    func addConstraintsToInviteButton() {
        inviteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: inviteButton,
                           attribute: .Right,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Right,
                           multiplier: 1,
                           constant: -15.0).active = true

        NSLayoutConstraint(item: inviteButton,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 30.0).active = true

        NSLayoutConstraint(item: inviteButton,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 30.0).active = true

        NSLayoutConstraint(item: inviteButton,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -8).active = true

        inviteButton.setNeedsLayout()
    }

    func inviteButtonPressed(sender: AnyObject?) {
        let vc = InvitationViewController()
        vc.setParentVC(self)
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }

    func renderNowPlayingView() {
        nowPlayingView = NowPlayingView.instanceFromNib()
        nowPlayingView.playlistVC = self
        nowPlayingView.updateTrackDisplay()
        self.view.addSubview(nowPlayingView)
    }


    func addConstraintsToNowPlayingView() {
        nowPlayingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: nowPlayingView,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Left,
                           multiplier: 1,
                           constant: 0).active = true

        NSLayoutConstraint(item: nowPlayingView,
                           attribute: .Right,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Right,
                           multiplier: 1,
                           constant: 0).active = true

        NSLayoutConstraint(item: nowPlayingView,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -40).active = true

        nowPlayingView.updateConstraints()
    }

    func showNowPlayingView() {
        slideDownViewHidden.active = false
        slideDownViewPosition1.active = false
        UIView.animateWithDuration(0.15, animations: {
            self.slideDownViewPosition2.active = true
            self.slideDownView.layoutIfNeeded()
        })
    }

    func hideNowPlayingView() {
        slideDownViewHidden.active = false
        slideDownViewPosition2.active = false
        UIView.animateWithDuration(0.15, animations: {
            self.slideDownViewPosition1.active = true
            self.slideDownView.layoutIfNeeded()
        })
    }

    func renderPlaylistIdLabel() {
        playlistIdLabel = Style.defaultLabel()
        playlistIdLabel.textColor = Style.primaryColor
        playlistIdLabel.font = Style.defaultFont(15)
        self.view.addSubview(playlistIdLabel)
        playlistIdLabel.text = playlistId
        playlistIdLabel.textAlignment = .Left
    }

    func addConstraintsToPlaylistIdLabel() {
        playlistIdLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: playlistIdLabel,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Left,
                           multiplier: 1,
                           constant: 20.0).active = true

        NSLayoutConstraint(item: playlistIdLabel,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 100.0).active = true

        NSLayoutConstraint(item: playlistIdLabel,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 30.0).active = true


        NSLayoutConstraint(item: playlistIdLabel,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -10.0).active = true

        playlistIdLabel.updateConstraints()

        let idLabel = Style.defaultLabel()
        idLabel.text = "ID"
        idLabel.textAlignment = .Center
        idLabel.font = Style.defaultFont(7)
        self.view.addSubview(idLabel)

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: idLabel,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -8).active = true


        NSLayoutConstraint(item: idLabel,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: playlistIdLabel,
                           attribute: .CenterX,
                           multiplier: 1,
                           constant: -5.0).active = true

        NSLayoutConstraint(item: idLabel,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: playlistIdLabel,
                           attribute: .Width,
                           multiplier: 1,
                           constant: 0.0).active = true

        idLabel.updateConstraints()
    }

    func renderPlaylistNameLabel() {
        playlistNameLabel = Style.defaultLabel()
        playlistNameLabel.font = Style.defaultFont(19)
        playlistNameLabel.textColor = Style.primaryColor
        self.view.addSubview(playlistNameLabel)
        playlistNameLabel.text = playlistName
        playlistNameLabel.textAlignment = .Center

    }

    func addConstraintsToPlaylistNameLabel() {
        playlistNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: playlistNameLabel,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -10).active = true


        NSLayoutConstraint(item: playlistNameLabel,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .CenterX,
                           multiplier: 1,
                           constant: 0.0).active = true

        NSLayoutConstraint(item: playlistNameLabel,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 30).active = true

        playlistNameLabel.updateConstraints()

        let playlistLabel = Style.defaultLabel()
        playlistLabel.text = "Playlist"
        playlistLabel.font = Style.defaultFont(7)
        self.view.addSubview(playlistLabel)

        playlistLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: playlistLabel,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -8).active = true


        NSLayoutConstraint(item: playlistLabel,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .CenterX,
                           multiplier: 1,
                           constant: 0.0).active = true

        playlistLabel.updateConstraints()

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

        self.tableView.addSubview(self.refreshControl)
        //        self.view.sendSubviewToBack(tableView)
        disableRefreshControl()
    }

    func addConstraintsToTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: tableView,
                           attribute: .Top,
                           relatedBy: .Equal,
                           toItem: slideDownView,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: 0).active = true

        NSLayoutConstraint(item: tableView,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Left,
                           multiplier: 1,
                           constant: 2).active = true

        NSLayoutConstraint(item: tableView,
                           attribute: .Right,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Right,
                           multiplier: 1,
                           constant: 2).active = true

        NSLayoutConstraint(item: tableView,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: 0).active = true

        tableView.updateConstraints()
    }

    func renderStartButton(){
        startButton = Style.circularButton(11.0)
        startButton.setTitle("Start", forState: .Normal)
        startButton.addTarget(self, action: #selector(PlaylistController.startPlaylist(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(startButton)
    }

    func addConstraintsToStartButton() {
        startButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: startButton,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Bottom,
                           multiplier: 1,
                           constant: -10.0).active = true

        NSLayoutConstraint(item: startButton,
                           attribute: .Height,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 50).active = true

        NSLayoutConstraint(item: startButton,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: 50).active = true

        startShown = NSLayoutConstraint(item: startButton,
                                        attribute: .Left,
                                        relatedBy: .Equal,
                                        toItem: self.view,
                                        attribute: .Left,
                                        multiplier: 1,
                                        constant: 10)
        startShown.active = false

        startHidden = NSLayoutConstraint(item: startButton,
                                         attribute: .Left,
                                         relatedBy: .Equal,
                                         toItem: self.view,
                                         attribute: .Left,
                                         multiplier: 1,
                                         constant: -50)
        startHidden.active = true

        startButton.updateConstraints()
    }

    func showStart() {
        self.startHidden.active = false
        UIView.animateWithDuration(0.15, animations: {
            self.startShown.active = true
            self.startButton.layoutIfNeeded()
        })
    }

    func hideStart() {
        self.startShown.active = false
        UIView.animateWithDuration(0.15, animations: {
            self.startHidden.active = true
            self.startButton.layoutIfNeeded()
        })
    }

    func getNextSong() -> Song? {
        if sortedSongs.count > 0 {
            return Song(songDoc: sortedSongs[0])
        }
        else {
            return nil
        }
    }

    func displayNextSong() {
        dispatch_async(dispatch_get_main_queue(), {
            activityIndicator.showComplete("")
            self.nowPlayingView.updateTrackDisplay()
        })
    }


    func startPlaylist(sender: AnyObject){
        nowPlayingView.playNextSong()
        playlistStarted = true
        hideStart()
        showNowPlayingView()
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
            if isHost {
                self.nowPlayingView.stop()
            }
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

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if sortedSongs.count > 5 {
            hideAddTrack()
        }
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        showAddTrack()
    }

    func updateTable() {

        sortedSongs = songs.sortedByScore()
        self.tableView.reloadData()
        
        if isHost && !playlistStarted && songs.count >= 1 {
            showStart()
        } else if songs.count == 0 && nowPlaying == nil {
            playlistStarted = false
            hideNowPlayingView()
        } else if nowPlaying != nil {
            showNowPlayingView()
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.updateTable()
        refreshControl.endRefreshing()
    }


}
