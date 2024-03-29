//
//  SettingsViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

class SettingsViewController: DefaultViewController {

    @IBOutlet var topAreaHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBOutlet var settingsControllerView: SettingsController!
    // have to do custom displaying of the
    // top settings panel in the yellow area
    
    @IBAction func leaveSettingsDidPress(sender: UIBarButtonItem) {
        (navigationController as! NavigationController).popSettings()
    }

    internal func showSettings(settingsDisplay: SettingsDisplay) {
        settingsControllerView.showSettings(settingsDisplay)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SongViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "SongViewCell")
        // this must be done here
    }

    @IBAction func didToggleSegmentedControl(sender: UISegmentedControl) {
        tableView.reloadData()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var song: SearchSong!
        if segmentedControl.selectedSegmentIndex == 0 {
            song = SongHandler.fetchSuggestions()[indexPath.row]
        } else {
            song = SongHandler.fetchFavorites()[indexPath.row]
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell") as! SongViewCell
        cell.loadItem(song)
        return cell;
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let suggestAction = UITableViewRowAction(style: .Normal, title: "Suggest", handler: self.suggestSong)
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: self.deleteSong)
        return [deleteAction,suggestAction]
    }

    func suggestSong(action: UITableViewRowAction, indexPath: NSIndexPath) {
        var song: SearchSong!
        if segmentedControl.selectedSegmentIndex == 0 {
            song = SongHandler.fetchSuggestions()[indexPath.row]
        } else {
            song = SongHandler.fetchFavorites()[indexPath.row]
        }

        APIHandler.addSongToDatabase(song, completion: {
            (result: Song?) in
            (self.navigationController as! NavigationController).popSettings()
            NSNotificationCenter.defaultCenter().postNotificationName(updatePlaylistKey, object: nil)
        })
    }

    func deleteSong(action: UITableViewRowAction, indexPath: NSIndexPath) {
        var song: SearchSong
        if segmentedControl.selectedSegmentIndex == 0 {
            song = SongHandler.fetchSuggestions()[indexPath.row]
            SongHandler.removeItemFromSuggestions(song)
        } else {
            song = SongHandler.fetchFavorites()[indexPath.row]
            SongHandler.removeItemFromFavorites(song)
        }
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var dataSource: [SearchSong]!
        if segmentedControl.selectedSegmentIndex == 0 {
            dataSource = SongHandler.fetchSuggestions()
        } else {
            dataSource = SongHandler.fetchFavorites()
        }
        return dataSource.count
    }
}