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

class PlaylistViewController: UIViewController {

    @IBOutlet var historyButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var leaveButton: UIButton!
    @IBOutlet var inviteButton: UIButton!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var playerContainer: UIView!
    @IBOutlet var playerContainerHeightConstraint: NSLayoutConstraint!

    private var playerDisplayType: PlayerDisplayType = .StartButton

    @IBOutlet var startButton: UIButton!
    private var smallPlayer: SmallMusicPlayerView!
//    private var largePlayer: UIView = UIView()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        startButton = ....
//        smallPlayer = NSBundle.mainBundle().loadNibNamed("SmallMusicPlayerView", owner: self, options: nil).first as! SmallMusicPlayerView

    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
        // register the table view cells
//        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
//        tableView.registerNib(nib,forCellReuseIdentifier: "songCell")
//    }

    internal func updatePlayerDisplay(newDisplayType: PlayerDisplayType) {
        if playerDisplayType != newDisplayType {
            playerDisplayType = newDisplayType
            playerContainer.subviews.forEach({
                // disable all constraints, remove from views
                $0.constraints.forEach({$0.active = false})
                $0.removeFromSuperview()
            })
            // switch on the type, add appropriate one
            playerContainerHeightConstraint.constant = playerDisplayType.heightValue()

            if playerDisplayType == .StartButton {
                // this should be sufficient?
                playerContainer.addSubview(startButton)
                playerContainer.bringSubviewToFront(startButton)
                print(playerContainer.subviews)
                startButton.constraints.forEach({$0.active = true})
//                startButton.center = playerContainer.center
//                startButton.setNeedsLayout()
//                startButton.setNeedsDisplay()
                startButton.updateConstraints()
                // add a start button
                // constraints

            } else if playerDisplayType == .Small {
                // add a small player
                smallPlayer = NSBundle.mainBundle().loadNibNamed("SmallMusicPlayerView", owner: self, options: nil).first as! SmallMusicPlayerView
                playerContainer.addSubview(smallPlayer)
                // constraints

            } else if playerDisplayType == .Large {
                // add a large player
                // constraints

                // to be implemented later
            }
            playerContainer.updateConstraints()

            playerContainer.setNeedsDisplay()
            playerContainer.setNeedsLayout()
            self.view.setNeedsDisplay()
            self.view.setNeedsLayout()
            // is this line correct? I'm not sure.
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



}


extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SongHandler.getSongsInQueue().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("songCell")! as! SongTableViewCell
        cell.selectionStyle = .None

        // add a long press action

        let (songId, song) = SongHandler.getQueuedSongByIndex(indexPath.row)
        cell.loadItem(songId, song: song)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}