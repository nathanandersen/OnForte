//
//  ProfileViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/6/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SafariServices

/**
 The ProfileViewController controls the user profile
 */
class ProfileViewController: UIViewController, SPTAuthViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var hostSettingsView: UIView!

    @IBOutlet var spotifyImageView: UIImageView!
    @IBOutlet var spotifyInfoView: UIView!

    @IBOutlet var soundCloudImageView: UIImageView!
    @IBOutlet var soundCloudInfoView: UIView!

    @IBOutlet var iTunesImageView: UIImageView!
    @IBOutlet var iTunesInfoView: UIView!

    @IBOutlet var profileImage: UIImageView!
    let sptAuthenticator = SPTAuth.defaultInstance()


    var timer: NSTimer!

    @IBOutlet var showHostSettingsConstraintTop: NSLayoutConstraint!

    @IBOutlet var trailingMarginOfLogins: NSLayoutConstraint!
    @IBOutlet var internalMarginBetweenImageAndLogins: NSLayoutConstraint!
    var showHostSettingsConstraint: NSLayoutConstraint!
    var hideHostSettingsConstraint: NSLayoutConstraint!

    var centerProfileImageConstraint: NSLayoutConstraint!

    var safariVC: SFSafariViewController!

    @IBOutlet var tableView: UITableView!

    @IBOutlet var segmentedControl: UISegmentedControl!
//    var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {

        super.viewDidLoad()
        // temporary work-around
        self.view.frame = CGRect(x: 0, y: 40, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 40)


        addVariableConstraints()
        renderTableView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.didLogInToSpotify), name: "didLogInToSpotify", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.displayHostSettings), name: "displayHostSettings", object: nil)
        if PlaylistHandler.isHost {
            displayHostSettings()
        }
        self.navigationItem.setHidesBackButton(true, animated: true)




    }

    func renderTableView() {


        let nib = UINib(nibName: "SongViewCell", bundle: nil)
        tableView.registerNib(nib,forCellReuseIdentifier: "SongViewCell")

//        tableView.registerClass(SongViewCell.self, forCellReuseIdentifier: "SongViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 85.0
        tableView.allowsSelection = false

        segmentedControl.addTarget(self, action: #selector(ProfileViewController.didToggleSegmentedControl), forControlEvents: .ValueChanged)
    }

    func didToggleSegmentedControl() {
        tableView.reloadData()
    }

    func updateProfileDisplay() {
        if PlaylistHandler.isHost {
            displayHostSettings()
        } else {
            hideHostSettings()
        }
        tableView.reloadData()
    }


    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Logged In")
        PlaylistHandler.spotifySession = session
//        spotifySession = session
        self.didLogInToSpotify()

    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("Failed to Log In")
        print(error)
        authenticationViewController.clearCookies(nil)
    }

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("User Canceled Log In")

        // VISUAL CONFIRMATION

        authenticationViewController.clearCookies(nil)
    }

    func updateLogins() {
        renderSpotifyLogin()
        renderSoundCloudLogin()
        renderiTunesLogin()
    }

    func addVariableConstraints() {
        hideHostSettingsConstraint = NSLayoutConstraint(item: hostSettingsView,
                                                        attribute: .Left,
                                                        relatedBy: .Equal,
                                                        toItem: self.view,
                                                        attribute: .Right,
                                                        multiplier: 1,
                                                        constant: 50)
        hideHostSettingsConstraint.identifier = "hide host settings off the right"
        centerProfileImageConstraint = NSLayoutConstraint(item: profileImage, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        centerProfileImageConstraint.identifier = "center the profile image"
    }

    func hideHostSettings() {
        //        updateLogins()
        showHostSettingsConstraintTop.active = false
        internalMarginBetweenImageAndLogins.active = false
        trailingMarginOfLogins.active = false
        hideHostSettingsConstraint.active = true
        centerProfileImageConstraint.active = true
        self.updateViewConstraints()
    }

    func displayHostSettings() {
        updateLogins()
        centerProfileImageConstraint.active = false
        hideHostSettingsConstraint.active = false
        trailingMarginOfLogins.active = true
        internalMarginBetweenImageAndLogins.active = true
        showHostSettingsConstraintTop.active = true
        self.updateViewConstraints()
    }

    func loginWithSpotify() {
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        spotifyAuthenticationViewController.modalPresentationStyle = .OverCurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)

        //        self.presentViewController(sptAuthController, animated: true, completion: nil)

        //        safariVC = SFSafariViewController(URL: NSURL(string: SPTAuth.defaultInstance().loginURL.absoluteString)!)
        //        self.presentViewController(safariVC, animated: true, completion: nil)
    }

    func didLogInToSpotify() {
        //        safariVC.dismissViewControllerAnimated(true, completion: nil)
        self.renderSpotifyLogin()
    }

    func renderSpotifyLogin() {
        spotifyInfoView.subviews.forEach() { $0.removeFromSuperview() }
        if PlaylistHandler.spotifySessionIsValid() {
//        if spotifySession != nil {
            renderGuestButton("spotify", imageView: spotifyImageView, infoView: spotifyInfoView, text: "Enabled", textColor: UIColor.greenColor())
        }
        else {
            spotifyImageView.image = UIImage(named: "spotify_gray")
            let spotifyLoginView = UIImageView(image: UIImage(named: "log_in-mobile"))
            spotifyInfoView.addSubview(spotifyLoginView)
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.loginWithSpotify))
            spotifyLoginView.userInteractionEnabled = true
            spotifyLoginView.addGestureRecognizer(tapGestureRecognizer)

            let heightConstraint = NSLayoutConstraint(item: spotifyLoginView,
                                                      attribute: .Height,
                                                      relatedBy: .Equal,
                                                      toItem: spotifyImageView,
                                                      attribute: .Height,
                                                      multiplier: 1,
                                                      constant: -10)

            let proportionConstraint = NSLayoutConstraint(item: spotifyLoginView,
                                                          attribute: .Height,
                                                          relatedBy: .Equal,
                                                          toItem: spotifyLoginView,
                                                          attribute: .Width,
                                                          multiplier: 88/488,
                                                          constant: 0)
            let leftConstraint = NSLayoutConstraint(item: spotifyLoginView,
                                                    attribute: .Left,
                                                    relatedBy: .Equal,
                                                    toItem: spotifyInfoView,
                                                    attribute: .Left,
                                                    multiplier: 1,
                                                    constant: 0)
            let rightConstraint = NSLayoutConstraint(item: spotifyLoginView,
                                                     attribute: .Right,
                                                     relatedBy: .Equal,
                                                     toItem: spotifyInfoView,
                                                     attribute: .Right,
                                                     multiplier: 1,
                                                     constant: 0)
            let middleConstraint = NSLayoutConstraint(item: spotifyLoginView,
                                                      attribute: .CenterY,
                                                      relatedBy: .Equal,
                                                      toItem: spotifyInfoView,
                                                      attribute: .CenterY,
                                                      multiplier: 1,
                                                      constant: 0)
            let centerConstraint = NSLayoutConstraint(item: spotifyLoginView,
                                                      attribute: .CenterX,
                                                      relatedBy: .Equal,
                                                      toItem: spotifyInfoView,
                                                      attribute: .CenterX,
                                                      multiplier: 1, constant: 0)

            let constraints = [heightConstraint,proportionConstraint,leftConstraint,
                               rightConstraint,middleConstraint,centerConstraint]
            spotifyLoginView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(constraints)
        }
    }

    func renderSoundCloudLogin() {
        soundCloudInfoView.subviews.forEach() { $0.removeFromSuperview() }
        // yes, this is unnecessary, but leaving the structure for future development
//        if true {
            renderGuestButton("soundcloud",imageView: soundCloudImageView,infoView: soundCloudInfoView, text: "Enabled", textColor: UIColor.orangeColor())
//        } else {
//            renderGuestButton("soundcloud_gray",imageView: soundCloudImageView,infoView: soundCloudInfoView, text: "Disabled", textColor: UIColor.grayColor())
//        }
    }

    func renderiTunesLogin() {
        iTunesInfoView.subviews.forEach() { $0.removeFromSuperview() }
        // yes, this is unnecessary, but leaving the structure for future development
//        if true {
            renderGuestButton("itunes", imageView: iTunesImageView, infoView: iTunesInfoView, text: "Enabled", textColor: UIColor.redColor())
//        } else {
//            renderGuestButton("itunes_gray", imageView: iTunesImageView, infoView: iTunesInfoView, text: "Disabled", textColor: UIColor.grayColor())
//        }
    }

    func renderGuestButton(imageName: String, imageView: UIImageView, infoView: UIView, text: String, textColor: UIColor) {
        imageView.image = UIImage(named: imageName)
        let label = Style.defaultLabel()
        label.textAlignment = .Left
        label.text = text
        label.textColor = textColor
        infoView.addSubview(label)
        let constraints = Style.constrainToBoundsOfFrame(label, parentView: infoView)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }



    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var dataSource: [Song]!
        if segmentedControl.selectedSegmentIndex == 0 {
            dataSource = SongHandler.fetchSuggestions()
        } else {
            dataSource = SongHandler.fetchFavorites()
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell") as! SongViewCell
        let song = dataSource[indexPath.row]
        print(song.service!)
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
        activityIndicator.showActivity("Adding song..")
        var song: Song!
        if segmentedControl.selectedSegmentIndex == 0 {
            song = SongHandler.fetchSuggestions()[indexPath.row]
        } else {
            song = SongHandler.fetchFavorites()[indexPath.row]
        }

        SearchHandler.addSongToDatabase(song, completionHandler: {
            activityIndicator.showComplete("")
            centralNavigationController.leaveProfile()
        })
    }

    func deleteSong(action: UITableViewRowAction, indexPath: NSIndexPath) {
        var song: Song!
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
        var dataSource: [Song]!
        if segmentedControl.selectedSegmentIndex == 0 {
            dataSource = SongHandler.fetchSuggestions()
        } else {
            dataSource = SongHandler.fetchFavorites()
        }
        return dataSource.count
    }
}
