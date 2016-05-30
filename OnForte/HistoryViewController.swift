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
        return SongHandler.getHistorySongs().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell")! as! SongViewCell
        cell.selectionStyle = .None

        let historySong = SongHandler.getHistorySongs()[indexPath.row]

        cell.loadItem(SearchSong(title: historySong.title, annotation: historySong.annotation, musicPlatform: MusicPlatform(str: historySong.musicPlatform!), artworkURL: NSURL(string: historySong.artworkURL!), trackId: historySong.trackId!))
        return cell
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let favoriteAction = UITableViewRowAction(style: .Destructive, title: "Save", handler: self.addToFavorites)
        return [favoriteAction]
    }

    func addToFavorites(action: UITableViewRowAction, indexPath: NSIndexPath) {
        let item = SongHandler.getHistorySongs()[indexPath.row]
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