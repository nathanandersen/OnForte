//
//  SearchViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {

    var navBar: UIView!

    var searchBar: UISearchBar!

    var activityIndicator: UIActivityIndicatorView!
    var searchTimer = NSTimer()

    var segmentedControl: UISegmentedControl!
    var selectionBar: UIView = UIView()
    var tableView: UITableView!
    var currentService: Service = .Soundcloud

    let translucentColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)


    let orderedServices: [Service] = [.Spotify, .Soundcloud, .iTunes]
    let orderedSearchHandlers: [SearchHandler] = [SpotifyHandler(),SoundCloudHandler(),LocalHandler()]

    let leftSelectedImage: UIImage = imageWithImage(UIImage(named: "spotify")!, scaledToSize: CGSizeMake(35, 35))
    let leftImage: UIImage = imageWithImage(UIImage(named: "spotify_gray")!, scaledToSize: CGSizeMake(35, 35))
    let centerSelectedImage: UIImage = imageWithImage(UIImage(named: "soundcloud")!, scaledToSize: CGSizeMake(35, 35))
    let centerImage: UIImage = imageWithImage(UIImage(named: "soundcloud_gray")!, scaledToSize: CGSizeMake(35, 35))
    let rightSelectedImage: UIImage = imageWithImage(UIImage(named: "itunes")!, scaledToSize: CGSizeMake(35, 35))
    let rightImage: UIImage = imageWithImage(UIImage(named: "itunes_gray")!, scaledToSize: CGSizeMake(35, 35))


    override func viewDidLoad() {
        super.viewDidLoad()
        let navHeight = centralNavigationController.navigationBar.bounds.maxY + UIApplication.sharedApplication().statusBarFrame.height
        self.view.frame = CGRectMake(UIScreen.mainScreen().bounds.width-drawerWidth, navHeight, drawerWidth, drawerHeight-navHeight)
        print(self.view.frame)

        self.view.backgroundColor = Style.whiteColor
        self.automaticallyAdjustsScrollViewInsets = false

        initializeNavBar()
        initializeTableView()
        addConstraints()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.reloadTable), name: "reloadSearchResults", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.closeSearch), name: "completeSearch", object: nil)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SearchViewController.handlePan(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    func handlePan(gesture: UIPanGestureRecognizer) {
        let gesture = gesture.velocityInView(self.view)
        if gesture.x > 0 {
            self.closeSearch()
        }
    }

    func closeSearch() {
        self.searchBar.text = ""
        orderedSearchHandlers.forEach() { $0.clearSearch() }
        self.view.endEditing(true)
        self.tableView.reloadData()
        self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
    }

    func reloadTable() {
        activityIndicator.stopAnimating()
        self.tableView.reloadData()
    }

    func initializeNavBar(){
        navBar = UIView()
        navBar.backgroundColor = Style.whiteColor
        self.view.addSubview(navBar)

        initializeSearchBar()
        initializeSegmentedControl()
    }

    func initializeSearchBar() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .Prominent
        searchBar.delegate = self
//        searchBar.tintColor = Style.blackColor // sets the font stuffs
        searchBar.barTintColor = Style.whiteColor // sets the boundary tint color
        searchBar.showsBookmarkButton = false
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search for a song"
        searchBar.translucent = false
        navBar.addSubview(searchBar)
        initializeActivityIndicator()
    }

    func initializeTableView() {
        tableView = UITableView()
        tableView.rowHeight = 85.0
        tableView.keyboardDismissMode = .OnDrag

        tableView.delegate = orderedSearchHandlers[0]
        tableView.dataSource = orderedSearchHandlers[0]

        tableView.registerClass(SongViewCell.self, forCellReuseIdentifier: "SongViewCell")
        self.view.addSubview(tableView)
    }

    func initializeActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = Style.blackColor
        activityIndicator.tintColor = Style.blackColor
        navBar.addSubview(activityIndicator)
    }

    func segmentedBarChangedValue(segment: UISegmentedControl) {
        let index = segment.selectedSegmentIndex
        print(index)
        switch(index) {
        case 0:
            segment.setImage(leftSelectedImage, forSegmentAtIndex: 0)
            segment.setImage(centerImage, forSegmentAtIndex: 1)
            segment.setImage(rightImage,forSegmentAtIndex: 2)
        case 1:
            segment.setImage(leftImage, forSegmentAtIndex: 0)
            segment.setImage(centerSelectedImage, forSegmentAtIndex: 1)
            segment.setImage(rightImage,forSegmentAtIndex: 2)
        case 2:
            segment.setImage(leftImage, forSegmentAtIndex: 0)
            segment.setImage(centerImage, forSegmentAtIndex: 1)
            segment.setImage(rightSelectedImage,forSegmentAtIndex: 2)
        case _:
            print("oops! only should be 3!")
        }
        tableView.dataSource = orderedSearchHandlers[index]
        tableView.delegate = orderedSearchHandlers[index]
        orderedSearchHandlers[index].search(searchBar.text!)
        searchTimer.invalidate()
        tableView.reloadData()
    }


    func initializeSegmentedControl(){
        // height = 40

        segmentedControl = UISegmentedControl(items: [leftImage,centerImage,rightImage])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(SearchViewController.segmentedBarChangedValue(_:)), forControlEvents: .ValueChanged)
        segmentedControl.tintColor = Style.translucentColor

        segmentedControl.subviews[0].tintColor = Style.spotifyGreen
        segmentedControl.subviews[1].tintColor = Style.orangeColor
//        segmentedControl.subviews[1].tintColor = Style.soundcloudOrange
        // ^ maybe make this "soundcloud orange"
        segmentedControl.subviews[2].tintColor = Style.redColor

        navBar.addSubview(segmentedControl)
    }

    func addConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        navBar.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        selectionBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: searchBar, attribute: .Left, relatedBy: .Equal, toItem: navBar, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Right, relatedBy: .Equal, toItem: navBar, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal, toItem: navBar, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40).active = true


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
        print(searchBar.text)
        searchTimer.invalidate()
        activityIndicator.stopAnimating()
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(SearchViewController.searchAll), userInfo: nil, repeats: true)
    }

    func searchAll(){
        activityIndicator.startAnimating()
        orderedSearchHandlers.forEach() { $0.search(searchBar.text!) }
        searchTimer.invalidate()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

}
