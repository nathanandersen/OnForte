//
//  HistoryViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/27/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

let updateHistoryTableKey = "updateHistoryTable"

class HistoryViewController: DefaultViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SongViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "SongViewCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HistoryViewController.updateTable), name: updateHistoryTableKey, object: nil)
    }

    func presentNewPlaylist() {
        updateTable()
    }

    func updateTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SongHandler.getPlaylistHistoryCount()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell")! as! SongViewCell
        cell.selectionStyle = .None

        let (_, song) = SongHandler.getPlayedSongByIndex(indexPath.row)
        cell.loadItem(InternalSong(songDoc: song))
//        cell.loadItem(songId, song: song)
        return cell
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let favoriteAction = UITableViewRowAction(style: .Destructive, title: "Save", handler: self.addToFavorites)
        return [favoriteAction]
    }

    func addToFavorites(action: UITableViewRowAction, indexPath: NSIndexPath) {
        let (_, songDoc) = SongHandler.getQueuedSongByIndex(indexPath.row)
        SongHandler.insertIntoFavorites(InternalSong(songDoc: songDoc))
        tableView.reloadData()
    }
}