//
//  SearchViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import UIKit

/**
 SearchViewController implements a search bar, a three-piece segment view to split
 between Spotify, SoundCloud, and local music, and a table view in which to display the
 data.
 
 It uses the SearchHandler protocol to determine which source the table's data is derived from.
 
 */
class SearchViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {

    var navBar: UIView!
    var searchBar: UISearchBar!
    var activityIndicator: UIActivityIndicatorView!
    var searchTimer = NSTimer()
    var segmentedControl: UISegmentedControl!
    var selectionBar: UIView = UIView()
    var tableView: UITableView!
    var currentService: Service = .Soundcloud
    let orderedServices: [Service] = [.Spotify, .Soundcloud, .iTunes]
    let orderedSearchHandlers: [SearchHandler] = [SpotifyHandler(),SoundCloudHandler(),LocalHandler()]

    let searchBarHeight: CGFloat = 40

    override func viewDidLoad() {
        super.viewDidLoad()
        let navHeight = centralNavigationController.navigationBar.bounds.maxY + UIApplication.sharedApplication().statusBarFrame.height
        self.view.frame = CGRectMake(UIScreen.mainScreen().bounds.width-drawerWidth, navHeight, drawerWidth, drawerHeight-navHeight)

        self.view.backgroundColor = Style.whiteColor
        self.automaticallyAdjustsScrollViewInsets = false

        initializeNavBar()
        initializeTableView()
        addConstraints()
        addNotificationsToGlobalCenter()

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SearchViewController.handlePan(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    /**
     Add the proper event listeners to the global center. 
     - Attention: Events:
        - reloadSearchResults -> data table reload
        - completeSearch -> finish the search
     */
    private func addNotificationsToGlobalCenter() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.reloadTable), name: "reloadSearchResults", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.closeSearch), name: "completeSearch", object: nil)
    }

    /**
     Handle a pan gesture. If swipe left, close the search.
    */
    internal func handlePan(gesture: UIPanGestureRecognizer) {
        let gesture = gesture.velocityInView(self.view)
        if gesture.x > 0 {
            self.closeSearch()
        }
    }

    /**
     Enable the search bar as first responder.
    */
    internal func enableSearchBar() {
        self.searchBar.becomeFirstResponder()
    }

    /**
     Close the search, and clear it.
    */
    internal func closeSearch() {
        self.searchBar.text = ""
        orderedSearchHandlers.forEach() { $0.clearSearch() }
        self.view.endEditing(true)
        self.tableView.reloadData()
        self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
    }

    /**
     Reload the table
    */
    internal func reloadTable() {
        activityIndicator.stopAnimating()
        self.tableView.reloadData()
    }

    /**
     Initialize the navbar
     - postcondition: The navbar and all subcomponents are initialized
    */
    private func initializeNavBar(){
        navBar = UIView()
        navBar.backgroundColor = Style.whiteColor
        self.view.addSubview(navBar)

        initializeSearchBar()
        initializeSegmentedControl()
    }

    /**
     Initialize the search bar.
     
     - postcondition: The search bar and all subcomponents are initialized
    */
    private func initializeSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .Prominent
        searchBar.delegate = self
        searchBar.barTintColor = Style.whiteColor // sets the boundary tint color
        searchBar.showsBookmarkButton = false
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search for a song"
        searchBar.translucent = false
        navBar.addSubview(searchBar)
        initializeActivityIndicator()
    }

    /**
     Initialize the table view
    */
    private func initializeTableView() {
        tableView = UITableView()
        tableView.rowHeight = 85.0
        tableView.keyboardDismissMode = .OnDrag
        tableView.delegate = orderedSearchHandlers[0]
        tableView.dataSource = orderedSearchHandlers[0]
        tableView.registerClass(SongViewCell.self, forCellReuseIdentifier: "SongViewCell")
        self.view.addSubview(tableView)
    }

    /**
     Initialize the activity indicator
    */
    private func initializeActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = Style.blackColor
        activityIndicator.tintColor = Style.blackColor
        navBar.addSubview(activityIndicator)
    }

    /**
     Handle when the segmented bar changed index.
     Set the table view data source / delegate to that SearchHandler
    */
    func segmentedBarChangedValue(segment: UISegmentedControl) {
        let index = segment.selectedSegmentIndex
        tableView.dataSource = orderedSearchHandlers[index]
        tableView.delegate = orderedSearchHandlers[index]
        orderedSearchHandlers[index].search(searchBar.text!)
        searchTimer.invalidate()
        tableView.reloadData()
    }

    /**
     Initialize the segmented control
    */
    private func initializeSegmentedControl(){
        let imageSize = CGSizeMake(searchBarHeight - 5, searchBarHeight - 5)
        let leftImage: UIImage = imageWithImage(UIImage(named: "spotify_gray")!, scaledToSize: imageSize)
        let centerImage: UIImage = imageWithImage(UIImage(named: "soundcloud_gray")!, scaledToSize: imageSize)
        let rightImage: UIImage = imageWithImage(UIImage(named: "itunes_gray")!, scaledToSize: imageSize)

        segmentedControl = UISegmentedControl(items: [leftImage,centerImage,rightImage])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(SearchViewController.segmentedBarChangedValue(_:)), forControlEvents: .ValueChanged)
        segmentedControl.tintColor = Style.translucentColor

        segmentedControl.subviews[0].tintColor = Style.spotifyGreen
        segmentedControl.subviews[1].tintColor = Style.orangeColor
//        segmentedControl.subviews[1].tintColor = Style.soundcloudOrange
        segmentedControl.subviews[2].tintColor = Style.redColor

        navBar.addSubview(segmentedControl)
    }

    /**
     Add all constraints to the view
    */
    private func addConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        navBar.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        selectionBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: searchBar, attribute: .Left, relatedBy: .Equal, toItem: navBar, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Right, relatedBy: .Equal, toItem: navBar, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal, toItem: navBar, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: searchBarHeight).active = true


        NSLayoutConstraint(item: navBar, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: navBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
        // **********
        NSLayoutConstraint(item: navBar, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.view.frame.minY + 1).active = true
        /// *********
        NSLayoutConstraint(item: navBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80).active = true

        NSLayoutConstraint(item: segmentedControl, attribute: .Left, relatedBy: .Equal, toItem: navBar, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: segmentedControl, attribute: .Right, relatedBy: .Equal, toItem: navBar, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: segmentedControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40).active = true
        NSLayoutConstraint(item: segmentedControl, attribute: .Top, relatedBy: .Equal, toItem: searchBar, attribute: .Bottom, multiplier: 1, constant: 1).active = true


        NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: activityIndicator, attribute: .Width, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: searchBar, attribute: .Height, multiplier: 1, constant: -5).active = true
        NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: searchBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: activityIndicator, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -60).active = true

        NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
         NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: navBar, attribute: .Bottom, multiplier: 1, constant: 5).active = true

        activityIndicator.updateConstraints()
        searchBar.updateConstraints()
        navBar.updateConstraints()
        segmentedControl.updateConstraints()
        tableView.updateConstraints()
    }

    // ***********************************      SEARCHING      ***********************************


    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer.invalidate()
        activityIndicator.stopAnimating()
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(SearchViewController.searchAll), userInfo: nil, repeats: true)
    }

    /**
     Search all SearchHandlers
    */
    internal func searchAll(){
        activityIndicator.startAnimating()
        orderedSearchHandlers.forEach() { $0.search(searchBar.text!) }
        searchTimer.invalidate()
    }
}
