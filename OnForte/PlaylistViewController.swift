//
//  PlaylistViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/25/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

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

class PlaylistViewController: DefaultViewController {

    @IBOutlet var historyButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var leaveButton: UIButton!
    @IBOutlet var inviteButton: UIButton!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var tableView: UITableView!

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



    internal func updatePlayerDisplay(newDisplayType: PlayerDisplayType) {
        if playerDisplayType != newDisplayType {
            playerDisplayType = newDisplayType
            playerContainerHeightConstraint.constant = newDisplayType.heightValue()
            startButton.hidden = (newDisplayType != .StartButton)
            smallMusicPlayer.hidden = (newDisplayType != .Small)
        }
    }


    internal func setPlaylistInfo(playlistName: String, playlistId: String) {
        nameLabel.text = playlistName
        idLabel.text = playlistId
    }
    @IBAction func startButtonDidPress(sender: AnyObject) {
        print("start button pressed")
    }

    @IBAction func historyButtonDidPress(sender: AnyObject) {
        print("history button pressed")
        updatePlayerDisplay(.StartButton)
    }
    @IBAction func searchButtonDidPress(sender: AnyObject) {
        print("search button pressed")
        updatePlayerDisplay(.Small)
    }
    @IBAction func leaveButtonDidPress(sender: AnyObject) {
        print("leave button pressed")
        updatePlayerDisplay(.None)
    }
    @IBAction func inviteButtonDidPress(sender: AnyObject) {
        print("invite button pressed")
    }

    @IBAction func profileButtonDidPress(sender: UIBarButtonItem) {
        (navigationController as! NavigationController).pushSettings()
    }


}

let songWasAddedKey: String = "songWasAdded"
extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistViewController.reloadTable), name: songWasAddedKey, object: nil)
        // register for table load notifications
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: songWasAddedKey, object: nil)
        // deregister
    }

    func reloadTable() {
        tableView.reloadData()
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