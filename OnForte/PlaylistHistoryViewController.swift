//
//  PlaylistHistoryViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP

class PlaylistHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var titleLabel: UILabel!
    var playedSongs = PlaylistSongHistory(name: "playedSongs")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let navHeight = centralNavigationController.navigationBar.bounds.maxY + UIApplication.sharedApplication().statusBarFrame.height
        self.view.frame = CGRectMake(0, navHeight, drawerWidth, drawerHeight-navHeight)


        renderTitleLabel()
        renderTableView()
        addConstraints()

        let paramObj = [playlistId!]
        Meteor.subscribe("playedSongs",params: paramObj)
    }

    func presentNewPlaylist() {
        self.updateTable()
    }

    func renderTitleLabel() {
        titleLabel = Style.defaultLabel()
        titleLabel.text = "Playlist History"
        titleLabel.textAlignment = .Center
        titleLabel.font = Style.defaultFont(20)
        self.view.addSubview(titleLabel)
    }

    func renderTableView() {
        tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.registerClass(SongViewCell.self, forCellReuseIdentifier: "SongViewCell")
//        tableView.registerClass(PlaylistHistoryTableViewCell.self, forCellReuseIdentifier: "PlaylistHistoryTableViewCell")
        tableView.rowHeight = 85.0
        tableView.tableHeaderView = nil;
        tableView.tableFooterView = UIView(frame: CGRectZero)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistHistoryViewController.updateTable), name:"reloadHistoryTable", object: nil)



    }

    func addConstraints() {
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

    func updateTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playedSongs.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell")! as! SongViewCell
        cell.selectionStyle = .None
        let songId = playedSongs.keys[indexPath.row]
//        print(songId)
        let song = playedSongs.findOne(songId)
//        print(song)
        cell.loadItem(songId,song: song!)
        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }

    
}
