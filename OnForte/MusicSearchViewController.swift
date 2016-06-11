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

    var orderedSearchHandlers: [SearchHandler] = []
    let spotifyHandler = SpotifyHandler()
    let soundcloudHandler = SoundcloudHandler()
    let appleMusicHandler = AppleMusicHandler()
    let localMusicHandler = LocalMusicHandler()

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
        var optionCount = 0
        print("started")

        if let p = PlaylistHandler.playlist {
            orderedSearchHandlers = []
            segmentedControl.removeAllSegments()

            if p.hostIsLoggedInToAppleMusic || (PlaylistHandler.isHost() && SongHandler.hasLocalLibrarySongs()) {
                segmentedControl.insertSegmentWithImage(UIImage(named: "itunes_gray")!, atIndex: 0, animated: true)
                segmentedControl.subviews[optionCount].tintColor = MusicPlatform.AppleMusic.tintColor()

                optionCount += 1

                if p.hostIsLoggedInToAppleMusic {
                    orderedSearchHandlers.insert(appleMusicHandler, atIndex: 0)
                } else {
                    // must be host and have songs
                    orderedSearchHandlers.insert(localMusicHandler, atIndex: 0)
                }
            }
            print("added apple music one or the other")
            if p.hostIsLoggedInToSoundcloud {
                segmentedControl.insertSegmentWithImage(UIImage(named: "soundcloud_gray")!, atIndex: 0, animated: true)
                segmentedControl.subviews[optionCount].tintColor = MusicPlatform.Soundcloud.tintColor()
                optionCount += 1
                orderedSearchHandlers.insert(soundcloudHandler, atIndex: 0)
            }
            print("added soundcloud")
            if p.hostIsLoggedInToSpotify {
                segmentedControl.insertSegmentWithImage(UIImage(named: "spotify_gray")!, atIndex: 0, animated: true)
                segmentedControl.subviews[optionCount].tintColor = MusicPlatform.Spotify.tintColor()
                optionCount += 1
                orderedSearchHandlers.insert(spotifyHandler, atIndex: 0)
            }
            print("added spotify")
            segmentedControl.selectedSegmentIndex = 0
            print("all done")
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