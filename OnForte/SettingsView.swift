//
//  HostSettingsView.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/27/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

let spotifyLoginKey = "didLogInToSpotify"

enum SettingsDisplay {
    case Guest
    case Host
}

class SettingsController: UIView {
    private var hostSettingsView: HostSettingsView!
    private var guestSettingsView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    internal func showSettings(settingsDisplay: SettingsDisplay) {
        hostSettingsView.hidden = (settingsDisplay != .Host)
        guestSettingsView.hidden = (settingsDisplay != .Guest)
        hostSettingsView.updateSpotifyLogin()
    }

    private func sharedInit() {
        hostSettingsView = NSBundle.mainBundle().loadNibNamed("HostSettingsView", owner: self, options: nil).first as! HostSettingsView
        guestSettingsView = NSBundle.mainBundle().loadNibNamed("GuestSettingsView", owner: self, options: nil).first as! UIView
        self.addSubview(hostSettingsView)
        self.addSubview(guestSettingsView)

        constrainToBoundsOfSelf(hostSettingsView)
        constrainToBoundsOfSelf(guestSettingsView)
    }

    private func constrainToBoundsOfSelf(view: UIView) {

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        view.updateConstraints()
    }
}

class HostSettingsView: UIView {

    @IBOutlet var spotifyLoginButton: UIButton!
    @IBOutlet var spotifyLoggedInLabel: UILabel!
    @IBOutlet var spotifyImage: UIImageView!
    @IBOutlet var soundcloudImage: UIImageView!
    @IBOutlet var itunesImage: UIImageView!
    let spotifyGrayImage = UIImage(named: "spotify_gray")
    let spotifyColorImage = UIImage(named: "spotify")

    @IBAction func spotifyLoginButtonDidPress(sender: UIButton) {
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        spotifyAuthenticationViewController.modalPresentationStyle = .OverCurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        self.window?.rootViewController!.presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)
    }
    internal func didLogInToSpotify() {
        spotifyImage.image = spotifyColorImage
        spotifyLoggedInLabel.hidden = false
        spotifyLoginButton.hidden = true
    }

    internal func updateSpotifyLogin() {
        let isLoggedIn = (PlaylistHandler.spotifySession != nil)
        spotifyLoggedInLabel.hidden = !isLoggedIn
        spotifyLoginButton.hidden = isLoggedIn
        spotifyImage.image = ((isLoggedIn) ? spotifyColorImage : spotifyGrayImage)
    }

    
}

extension HostSettingsView: SPTAuthViewDelegate {
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Logged In")
        PlaylistHandler.spotifySession = session
        self.didLogInToSpotify()
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("Failed to Log In")
        print(error)
        authenticationViewController.clearCookies(nil)
    }

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("User Canceled Log In")
        authenticationViewController.clearCookies(nil)

        let alertController = UIAlertController(title: "Login cancelled", message: "You have cancelled Spotify login.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        self.window?.rootViewController!.presentViewController(alertController, animated: false, completion: nil)

    }
}