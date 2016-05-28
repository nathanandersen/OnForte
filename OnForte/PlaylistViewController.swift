//
//  PlaylistViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/25/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import MessageUI

enum PlayerDisplayType {
    case None
    case StartButton
    case Small
    case Large

    func heightValue() -> CGFloat {
        if self == .None {
            return 0
        } else if self == .StartButton {
            return 40
        } else if self == .Small {
            return 80
        } else if self == .Large {
            return 320
        } else {
            fatalError()
        }
    }
}


let leaveAlertTitle = "Leave Playlist"
let guestLeaveMessage = "Are you sure you want to leave this playlist?"
let hostLeaveMessage = "You're the host, so leaving this playlist will end it for everyone."
let updatePlaylistInfoKey = "updatePlaylistInformation"

class PlaylistViewController: DefaultViewController {

    @IBOutlet var historyButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var leaveButton: UIButton!
    @IBOutlet var inviteButton: UIButton!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var playlistTabBarItem: UITabBarItem!
    /**
     The player container is just a placeholder for the height of the contents.
     It can contain nothing, a start button, or a small/large player.
    */
    private var playerDisplayType: PlayerDisplayType = .None
    @IBOutlet var playerContainer: UIView!
    @IBOutlet var playerContainerHeightConstraint: NSLayoutConstraint!

    @IBOutlet var startButton: UIButton!
//    private var largePlayer: UIView = UIView()
    @IBOutlet var smallMusicPlayer: SmallMusicPlayerController!

    private var alertController: UIAlertController?
    private var iMessageController: MFMessageComposeViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistViewController.presentNewPlaylist), name: updatePlaylistInfoKey, object: nil)
    }

    internal func updatePlayerDisplay(newDisplayType: PlayerDisplayType) {
        if playerDisplayType != newDisplayType {
            playerDisplayType = newDisplayType
            playerContainerHeightConstraint.constant = newDisplayType.heightValue()
            startButton.hidden = (newDisplayType != .StartButton)
            smallMusicPlayer.hidden = (newDisplayType != .Small)
        }
    }

    internal func showAPlayer(currentDisplayType: PlayerDisplayType) {
        if playerDisplayType != .Small || playerDisplayType != .Large {
            updatePlayerDisplay(.Small)
        }
    }

    /**
     Sets the playlist name and the playlist ID, from the PlaylistHandler
    */
    internal func presentNewPlaylist() {
        setPlaylistInfo(PlaylistHandler.playlistName, playlistId: PlaylistHandler.playlistId)
    }

    /**
     Sets the playlist name and ID from parameters.
     - parameter playlistName
     - parameter playlistId
    */
    internal func setPlaylistInfo(playlistName: String, playlistId: String) {
        nameLabel.text = playlistName
        self.title = playlistName

        idLabel.text = playlistId
    }
    @IBAction func startButtonDidPress(sender: AnyObject) {
        #if DEBUG
            print("start button pressed")
        #endif
        PlaylistHandler.togglePlayingStatus({ (result) in
            self.smallMusicPlayer.setIsPlaying(result)
        })
    }

    @IBAction func historyButtonDidPress(sender: AnyObject) {
        #if DEBUG
            print("history button pressed")
        #endif
        mm_drawerController.openDrawerSide(.Left, animated: true, completion: nil)
    }
    @IBAction func searchButtonDidPress(sender: AnyObject) {
        #if DEBUG
            print("search button pressed")
        #endif
        mm_drawerController.openDrawerSide(.Right, animated: true, completion: nil)
    }
    @IBAction func leaveButtonDidPress(sender: AnyObject) {
        #if DEBUG
            print("leave button pressed")
        #endif
        if alertController == nil {
            alertController = UIAlertController(title: leaveAlertTitle, message: guestLeaveMessage, preferredStyle: .Alert)
            alertController?.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

            alertController?.addAction(UIAlertAction(title: "Leave", style: .Destructive, handler: {
                _ in
                PlaylistHandler.leavePlaylist()
                (self.navigationController as? NavigationController)?.popPlaylist()
            }))
        }

        if PlaylistHandler.isHost {
            alertController?.message = hostLeaveMessage
        } else {
            alertController?.message = guestLeaveMessage
        }

        self.presentViewController(alertController!, animated: true, completion: nil)
    }

    @IBAction func inviteButtonDidPress(sender: AnyObject) {
        print("invite button pressed")
        sendInvitations()
    }

}

extension PlaylistViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {

    internal func sendInvitations() {
        if MFMessageComposeViewController.canSendText() {
            if iMessageController == nil {
                iMessageController = MFMessageComposeViewController()
                iMessageController!.messageComposeDelegate = self
                iMessageController!.body = "You've been invited to join a playlist on Forte at Forte://" + PlaylistHandler.playlistId + ". Don't have the app? Join the fun at www.onforte.com/" + PlaylistHandler.playlistId + " ."
            }
            iMessageController!.recipients = nil
            presentViewController(iMessageController!, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "iMessage unavailable", message: "We're sorry, iMessage seems to be unavailable at the moment. Try again later?", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        print("some sort of result happened")
        // this hasn't been debugged yet
        if result == MessageComposeResultFailed {
            // alert the user that it failed
            let alertController = UIAlertController(title: "Message failed", message: "We're sorry, iMessage did not deliver your messages. Try again?", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

let reloadTableKey: String = "reloadTable"
extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistViewController.reloadTable), name: reloadTableKey, object: nil)
        // register for table load notifications
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: reloadTableKey, object: nil)
        // deregister
    }

    func reloadTable() {
        var playerTypeToDisplay: PlayerDisplayType!
        if PlaylistHandler.nowPlaying == nil {
            if PlaylistHandler.isHost && SongHandler.getSongsInQueue().count >= 1 {
                playerTypeToDisplay = .StartButton
            } else {
                playerTypeToDisplay = .None
            }
        } else if playerDisplayType != .Small || playerDisplayType != .Large {
            playerTypeToDisplay = .Small
        } else {
            playerTypeToDisplay = playerDisplayType
        }

        dispatch_async(dispatch_get_main_queue(), {
            self.updatePlayerDisplay(playerTypeToDisplay)
            self.tableView.reloadData()
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SongHandler.getSongsInQueue().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell") as! PlaylistTableViewCell
        cell.selectionStyle = .None
        // add a long press action

        let (songId, song) = SongHandler.getQueuedSongByIndex(indexPath.row)
        cell.loadItem(songId,song: song)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}