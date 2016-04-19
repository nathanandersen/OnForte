//
//  SearchViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController/*, SMSegmentViewDelegate*/, UITextFieldDelegate {

    var navBar: UIView!

    var searchBar: UITextField!
    var cancelButton: UIButton!
    var activityIndicator: UIActivityIndicatorView!
    var searchTimer = NSTimer()

    var segmentedControl: UISegmentedControl!
//    var segmentedControl: SMSegmentView!

    var selectionBar: UIView = UIView()
    var searchBarUnderline: UIView!
    var searchBarIcon: UIImageView!

    var tableView: UITableView!

    var currentService: Service = .Soundcloud
//    var searchActive = false

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

//        segmentedControl.selectSegmentAtIndex(0)
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
        searchBar = UITextField()
        searchBar.backgroundColor = Style.blackColor

        searchBar.delegate = self
        searchBar.returnKeyType = .Search // just to fake it
        searchBar.addTarget(self, action: #selector(SearchViewController.searchTextChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        navBar.addSubview(searchBar)

        searchBar.backgroundColor = Style.clearColor
        searchBar.tintColor = Style.blackColor

        searchBarUnderline = UIView()
        navBar.addSubview(searchBarUnderline)
        searchBarUnderline.backgroundColor = Style.blackColor

        searchBarIcon = UIImageView()
        searchBarIcon.backgroundColor = Style.clearColor
        searchBarIcon.image = UIImage(named: "search")
        searchBarIcon.contentMode = UIViewContentMode.ScaleAspectFit
        navBar.addSubview(searchBarIcon)


        initializeCancelButton()
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


    func initializeCancelButton() {
        cancelButton = UIButton()
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.setTitleColor(Style.blackColor, forState: .Normal)
        cancelButton.setTitleColor(Style.grayColor, forState: .Highlighted)
        cancelButton.backgroundColor = Style.clearColor
        cancelButton.titleLabel?.font = Style.defaultFont(17)
        cancelButton.addTarget(self, action: #selector(SearchViewController.cancelButtonPressed(_:)), forControlEvents: .TouchUpInside)
        navBar.addSubview(cancelButton)
        self.view.addSubview(cancelButton)
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

//        segmentedControl.subviews[0].tintColor = Style.greenColor
        segmentedControl.subviews[0].tintColor = Style.spotifyGreen
        // ^ maybe make this "spotify green"
        segmentedControl.subviews[1].tintColor = Style.orangeColor
        // ^ maybe make this "soundcloud orange"
        segmentedControl.subviews[2].tintColor = Style.redColor

/*        segmentedControl = SMSegmentView()
        segmentedControl.separatorColour = Style.primaryColor
        segmentedControl.separatorWidth = 0.0
        segmentedControl.addSegmentWithTitle("Spotify", onSelectionImage: UIImage(named: "spotify"), offSelectionImage: UIImage(named: "spotify_gray"))
        segmentedControl.addSegmentWithTitle("Soundcloud", onSelectionImage: UIImage(named: "soundcloud"), offSelectionImage: UIImage(named: "soundcloud_gray"))
        if isHost {
            segmentedControl.addSegmentWithTitle("Music", onSelectionImage: UIImage(named: "itunes"), offSelectionImage: UIImage(named: "itunes_gray"))
        }
        segmentedControl.segmentTitleFont = Style.defaultFont(10)
        segmentedControl.segmentOffSelectionColour = Style.clearColor
        segmentedControl.segmentOnSelectionColour = Style.clearColor
        self.segmentedControl.layer.borderWidth = 0.0
        segmentedControl.delegate = self*/
        navBar.addSubview(segmentedControl)

/*        self.selectionBar.frame = CGRect(x: 0.0, y: self.segmentedControl.frame.size.height - 5.0, width: self.segmentedControl.frame.size.width/CGFloat(self.segmentedControl.numberOfSegments), height: 5.0)
        self.view.addSubview(selectionBar)*/
    }

    func addConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        navBar.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBarUnderline.translatesAutoresizingMaskIntoConstraints = false
        searchBarIcon.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        selectionBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: cancelButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -120).active = true
        NSLayoutConstraint(item: cancelButton, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: cancelButton, attribute: .CenterY, relatedBy: .Equal, toItem: searchBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: cancelButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 22).active = true


        NSLayoutConstraint(item: searchBarIcon, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 14).active = true
        NSLayoutConstraint(item: searchBarIcon, attribute: .CenterY, relatedBy: .Equal, toItem: searchBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBarIcon, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15).active = true
        NSLayoutConstraint(item: searchBarIcon, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 22).active = true


        NSLayoutConstraint(item: searchBarUnderline, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 15).active = true
        NSLayoutConstraint(item: searchBarUnderline, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -100).active = true
        NSLayoutConstraint(item: searchBarUnderline, attribute: .Top, relatedBy: .Equal, toItem: searchBar, attribute: .Bottom, multiplier: 1, constant: -2).active = true
        NSLayoutConstraint(item: searchBarUnderline, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 2).active = true


        NSLayoutConstraint(item: searchBar, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 35).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -150).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal, toItem: navBar, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: searchBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30).active = true


        NSLayoutConstraint(item: navBar, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: navBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
        // **********
        NSLayoutConstraint(item: navBar, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.view.frame.minY).active = true
        /// *********
        NSLayoutConstraint(item: navBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70).active = true

        NSLayoutConstraint(item: segmentedControl, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 2.5).active = true
        NSLayoutConstraint(item: segmentedControl, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -2.5).active = true
        NSLayoutConstraint(item: segmentedControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40).active = true
        NSLayoutConstraint(item: segmentedControl, attribute: .Top, relatedBy: .Equal, toItem: searchBar, attribute: .Bottom, multiplier: 1, constant: 0).active = true


        NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: activityIndicator, attribute: .Width, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: activityIndicator, attribute: .Height, relatedBy: .Equal, toItem: searchBar, attribute: .Height, multiplier: 1, constant: -5).active = true
        NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: searchBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: activityIndicator, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -120).active = true

        NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0).active = true
         NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
//        NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: navBar, attribute: .Bottom, multiplier: 1, constant: 10).active = true
        NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: navBar, attribute: .Bottom, multiplier: 1, constant: 5).active = true

/*        NSLayoutConstraint(item: selectionBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: selectionBar, attribute: .Width, relatedBy: .Equal, toItem: segmentedControl, attribute: .Width, multiplier: 1/CGFloat(self.segmentedControl.numberOfSegments), constant: 0).active = true
        NSLayoutConstraint(item: selectionBar, attribute: .Top, relatedBy: .Equal, toItem: segmentedControl, attribute: .Bottom, multiplier: 1, constant: 5).active = true*/


//        selectionBar.updateConstraints()
        cancelButton.updateConstraints()
        activityIndicator.updateConstraints()
        searchBarIcon.updateConstraints()
        searchBar.updateConstraints()
        searchBarUnderline.updateConstraints()
        navBar.updateConstraints()
        segmentedControl.updateConstraints()
        tableView.updateConstraints()
    }



    // *********************************** VIEW INITIALIZATION ***********************************

/*
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {

        print(index)

        let placeSelectionBar = { () -> () in
            var barFrame = self.selectionBar.frame
            barFrame.origin.x = barFrame.size.width * CGFloat(index)
            self.selectionBar.frame = barFrame
        }

        if self.selectionBar.superview == nil {
            self.segmentedControl.addSubview(self.selectionBar)
            placeSelectionBar()
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                placeSelectionBar()
            })
        }
        let orderedColors: [UIColor] = [Style.greenColor, Style.orangeColor, Style.redColor]
        currentService = orderedServices[index]
        selectionBar.backgroundColor = orderedColors[index]

        segmentedControl.segmentOnSelectionTextColour = orderedColors[index]

        tableView.dataSource = orderedSearchHandlers[index]
        tableView.delegate = orderedSearchHandlers[index]
        orderedSearchHandlers[index].search(searchBar.text!)
        searchTimer.invalidate()
        tableView.reloadData()

    }*/

    // ***********************************      SEARCHING      ***********************************

    func clearSearch() {
        orderedSearchHandlers.forEach() { $0.clearSearch() }
        self.view.endEditing(true)
        self.tableView.reloadData()
    }


    func cancelButtonPressed(sender: AnyObject) {
        self.mm_drawerController.closeDrawerAnimated(true, completion: nil)
    }

    // Called when text changes in search bar
    func searchTextChanged(sender: AnyObject) {
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

    func updateCurrentPageFromSwipe(index: Int){
        orderedSearchHandlers[index].search(searchBar.text!)
        searchTimer.invalidate()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

}
