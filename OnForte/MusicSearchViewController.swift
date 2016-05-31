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

    let orderedSearchHandlers: [SearchHandler] = [SpotifyHandler(),SoundcloudHandler(),AppleMusicHandler()]

    @IBOutlet var searchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    var timer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SongViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "SongViewCell")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MusicSearchViewController.updateSegmentedControlAccordingToPlaylist), name: updateSearchSegmentedControlKey, object: nil)

        //        customizeSegmentedControl()
        updateSegmentedControlAccordingToPlaylist()
    }

    @IBAction func handleScreenEdgePanGestureFromLeft(sender: UIScreenEdgePanGestureRecognizer) {
        (tabBarController as! PlaylistTabBarController).displayViewController(PlaylistViewController)
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

    internal func updateSegmentedControlAccordingToPlaylist() {
        if let p = PlaylistHandler.playlist {
            segmentedControl.removeAllSegments()
            if PlaylistHandler.isHost() /*|| p.hostIsLoggedInToAppleMusic*/ {
                segmentedControl.insertSegmentWithImage(UIImage(named: "itunes_gray")!, atIndex: 0, animated: true)
                segmentedControl.subviews[0].tintColor = MusicPlatform.AppleMusic.tintColor()
            }
            if p.hostIsLoggedInToSoundcloud {
                segmentedControl.insertSegmentWithImage(UIImage(named: "soundcloud_gray")!, atIndex: 0, animated: true)
                segmentedControl.subviews[1].tintColor = MusicPlatform.Soundcloud.tintColor()
            }
            if p.hostIsLoggedInToSpotify {
                segmentedControl.insertSegmentWithImage(UIImage(named: "spotify_gray")!, atIndex: 0, animated: true)
                segmentedControl.subviews[2].tintColor = MusicPlatform.Spotify.tintColor()
            }
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    @IBAction func segmentedControlChangedValue(sender: UISegmentedControl) {
        tableView.reloadData()
    }

    internal func closeSearch() {
        searchBar.text = ""
        orderedSearchHandlers.forEach() { $0.clearSearch() } // clear all SearchHandlers
        tableView.reloadData() // clear the table views
        self.view.endEditing(true)
        (tabBarController as! PlaylistTabBarController).displayViewController(PlaylistViewController)
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
        SearchHandler.addSongToPlaylist(orderedSearchHandlers[segmentedControl.selectedSegmentIndex].results[indexPath.row])
    }
}