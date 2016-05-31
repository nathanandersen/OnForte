//
//  PlaylistViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/25/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
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
    @IBOutlet var tableView: UITableView!

    @IBOutlet var playlistTabBarItem: UITabBarItem!
    /**
     The player container is just a placeholder for the height of the contents.
     It can contain nothing, a start button, or a small/large player.
    */
    private var playerDisplayType: PlayerDisplayType = .None
    @IBOutlet var playerContainer: UIView! // unnecessary
    @IBOutlet var playerContainerHeightConstraint: NSLayoutConstraint!

    @IBOutlet var startButton: UIButton!
//    private var largePlayer: UIView = UIView()
    @IBOutlet var smallMusicPlayer: SmallMusicPlayerController!

    private var alertController: UIAlertController?

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PlaylistViewController.refresh), forControlEvents: .ValueChanged)
        return refreshControl
    }()

    func refresh() {
        APIHandler.updateSongs()
        refreshControl.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(self.refreshControl)

        // if isHost()
        // implement an auto-refreshing timer
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
    internal func presentNewPlaylist() {
        tableView.reloadData()
        self.title = PlaylistHandler.playlist!.name
    }


    @IBAction func startButtonDidPress(sender: AnyObject) {
        #if DEBUG
            print("start button pressed")
        #endif
        PlaylistHandler.togglePlayingStatus({ (result) in
            self.smallMusicPlayer.setIsPlaying(result)
            APIHandler.updateSongs()
        })
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
        var playerTypeToDisplay: PlayerDisplayType
        if PlaylistHandler.nowPlaying == nil {
            if PlaylistHandler.isHost() && SongHandler.getQueuedSongs().count >= 1 {
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
        return SongHandler.getQueuedSongs().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell") as! PlaylistTableViewCell
        cell.selectionStyle = .None
        cell.loadItem(SongHandler.getQueuedSongs()[indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let favoriteAction = UITableViewRowAction(style: .Normal, title: "Save", handler: self.addToFavorites)
        return [favoriteAction]
    }

    func addToFavorites(action: UITableViewRowAction, indexPath: NSIndexPath) {
        let item = SongHandler.getQueuedSongs()[indexPath.row]
        SongHandler.insertIntoFavorites(
            SearchSong(title: item.title,
                annotation: item.annotation,
                musicPlatform: MusicPlatform(str: item.musicPlatform!),
                artworkURL: NSURL(string: item.artworkURL!),
                trackId: item.trackId!)
        )
        tableView.reloadData()
    }
}