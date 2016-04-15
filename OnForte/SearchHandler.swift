//
//  SearchHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation

protocol SearchHandler: UITableViewDelegate, UITableViewDataSource {

    var results: [Song] { get set }

    func search(query: String)

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)

    func addSongToPlaylist(song: Song)

    func clearSearch()
}
