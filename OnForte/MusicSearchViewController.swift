//
//  MusicSearchViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/27/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class MusicSearchViewController: DefaultViewController {

    let orderedSearchHandlers: [SearchHandler] = [SpotifyHandler(),SoundCloudHandler(),LocalHandler()]

    @IBOutlet var searchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    var timer = NSTimer()

    @IBAction func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
        if gesture.velocityInView(self.view).x > 0 {
            self.closeSearch()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SongViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "SongViewCell")

        customizeSegmentedControl()
    }

    internal func enableSearchBar() {
        searchBar.becomeFirstResponder()
    }

    private func customizeSegmentedControl() {
        // the colors and stuff
    }
    @IBAction func segmentedControlChangedValue(sender: UISegmentedControl) {
        tableView.reloadData()
    }

    internal func closeSearch() {
        searchBar.text = ""
        orderedSearchHandlers.forEach() { $0.clearSearch() } // clear all SearchHandlers
        tableView.reloadData() // clear the table views
        self.view.endEditing(true)
        self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
    }
}

extension MusicSearchViewController: UISearchBarDelegate {
    internal func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            search()
        }
    }

    internal func search() {
        timer.invalidate()
        searchActivityIndicator.stopAnimating()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.15, target: self, selector: #selector(MusicSearchViewController.searchAllHandlers), userInfo: nil, repeats: false)
    }

    internal func searchAllHandlers() {
        searchActivityIndicator.startAnimating()
        var counter = 3
        orderedSearchHandlers.forEach() {
            $0.search(searchBar.text!) { (success: Bool) in
                self.tableView.reloadData()
                counter -= 1
                if counter == 0 {
                    self.searchActivityIndicator.stopAnimating()
                }
            }
        }
    }

}

extension MusicSearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedSearchHandlers[segmentedControl.selectedSegmentIndex].results.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell") as! SongViewCell
        cell.loadItem(orderedSearchHandlers[segmentedControl.selectedSegmentIndex].results[indexPath.row])
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activityIndicator.showActivity("Adding Song")
        SearchHandler.addSongToPlaylist(orderedSearchHandlers[segmentedControl.selectedSegmentIndex].results[indexPath.row])
    }
}