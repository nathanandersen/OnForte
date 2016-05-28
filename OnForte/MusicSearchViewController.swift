//
//  MusicSearchViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/27/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

let closeSearchKey = "closeSearch"

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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MusicSearchViewController.closeSearch), name: closeSearchKey, object: nil)
        searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: closeSearchKey, object: nil)
    }

    private func customizeSegmentedControl() {
        segmentedControl.setImage(UIImage(named: "spotify_gray")!, forSegmentAtIndex: 0)
        segmentedControl.setImage(UIImage(named: "soundcloud_gray")!, forSegmentAtIndex: 1)
        segmentedControl.setImage(UIImage(named: "itunes_gray")!, forSegmentAtIndex: 2)
        // not sure why this is inverted, but.. ok
        segmentedControl.subviews[2].tintColor = Service.Spotify.tintColor()
        segmentedControl.subviews[1].tintColor = Service.Soundcloud.tintColor()
        segmentedControl.subviews[0].tintColor = Service.iTunes.tintColor()


    }
    @IBAction func segmentedControlChangedValue(sender: UISegmentedControl) {
        tableView.reloadData()
    }

    internal func closeSearch() {
        searchBar.text = ""
        orderedSearchHandlers.forEach() { $0.clearSearch() } // clear all SearchHandlers
        tableView.reloadData() // clear the table views
        self.view.endEditing(true)
        (tabBarController as! PlaylistTabBarController).displayViewController(.Main)
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
        orderedSearchHandlers.forEach() {
            let s = $0
            s.search(searchBar.text!) { (success: Bool) in
                if self.orderedSearchHandlers.indexOf(s)! == self.segmentedControl.selectedSegmentIndex {
                    self.searchActivityIndicator.stopAnimating()
                    self.tableView.reloadData()
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
//        activityIndicator.showActivity("Adding Song")
        SearchHandler.addSongToPlaylist(orderedSearchHandlers[segmentedControl.selectedSegmentIndex].results[indexPath.row])
    }
}