//
//  PlaylistHistoryViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP

/**
 A view controller to display a table containing the playlist history.
 
 */
class PlaylistHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let navHeight = centralNavigationController.navigationBar.bounds.maxY + UIApplication.sharedApplication().statusBarFrame.height
        self.view.frame = CGRectMake(0, navHeight, drawerWidth, drawerHeight-navHeight)

        renderTitleLabel()
        renderTableView()
        addConstraints()

//        let paramObj = [playlistId!]
//        Meteor.subscribe("playedSongs",params: paramObj)
    }

    /**
     PresentNewPlaylist prepares the controller for a new playlist, by reloading the (now empty) table
    */
    func presentNewPlaylist() {
        self.updateTable()
    }

    /**
     Render the title label and add it to the view
    */
    private func renderTitleLabel() {
        titleLabel = Style.defaultLabel()
        titleLabel.text = "Playlist History"
        titleLabel.textAlignment = .Center
        titleLabel.font = Style.defaultFont(20)
        self.view.addSubview(titleLabel)
    }

    /**
     Render the table view and add it to the view
    */
    private func renderTableView() {
        tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false

        let nib = UINib(nibName: "SongViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "SongViewCell")

//        tableView.registerClass(SongViewCell.self, forCellReuseIdentifier: "SongViewCell")
        tableView.rowHeight = 85.0
        tableView.tableHeaderView = nil;
        tableView.tableFooterView = UIView(frame: CGRectZero)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistHistoryViewController.updateTable), name:"reloadHistoryTable", object: nil)
    }

    /**
     Add all constraints to the view.
     */
    private func addConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.view.frame.minY).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true


        NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0).active = true

        tableView.updateConstraints()
        titleLabel.updateConstraints()
    }

    /**
     Update the table display on the main thread
    */
    func updateTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    /**
     UITableViewDelegate protocol
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SongHandler.getPlaylistHistoryCount()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell")! as! SongViewCell
        cell.selectionStyle = .None
        let (songId, song) = SongHandler.getPlayedSongByIndex(indexPath.row)
        cell.loadItem(songId, song: song)
        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     // tap to add to favs?
        print("You selected cell #\(indexPath.row)!")
    }

    
}
