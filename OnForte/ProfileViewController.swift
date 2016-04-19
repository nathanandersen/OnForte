//
//  ProfileViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/6/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SafariServices
import BFPaperButton

class ProfileViewController: UIViewController, SPTAuthViewDelegate {

    @IBOutlet var hostSettingsView: UIView!

    @IBOutlet var spotifyImageView: UIImageView!
    @IBOutlet var spotifyInfoView: UIView!

    @IBOutlet var soundCloudImageView: UIImageView!
    @IBOutlet var soundCloudInfoView: UIView!

    @IBOutlet var iTunesImageView: UIImageView!
    @IBOutlet var iTunesInfoView: UIView!

    let sptAuthenticator = SPTAuth.defaultInstance()


    var timer: NSTimer!

    var showHostSettingsConstraint: NSLayoutConstraint!
    var hideHostSettingsConstraint: NSLayoutConstraint!

    var safariVC: SFSafariViewController!

    override func viewDidLoad() {

        super.viewDidLoad()
        // temporary work-around
        self.view.frame = CGRect(x: 0, y: 40, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 40)


        addVariableConstraints()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.didLogInToSpotify), name: "didLogInToSpotify", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.displayHostSettings), name: "displayHostSettings", object: nil)
        if isHost {
            displayHostSettings()
        }
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Logged In")
        spotifySession = session
        self.didLogInToSpotify()
        //        self.displaySpotifyLogin()
        //        print(session.expirationDate)

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
        showHostSettingsConstraint = NSLayoutConstraint(item: hostSettingsView,
                                                        attribute: .CenterY,
                                                        relatedBy: .Equal,
                                                        toItem: self.view,
                                                        attribute: .CenterY,
                                                        multiplier: 1,
                                                        constant: 0)

        hideHostSettingsConstraint = NSLayoutConstraint(item: hostSettingsView,
                                                        attribute: .Bottom,
                                                        relatedBy: .Equal,
                                                        toItem: self.view,
                                                        attribute: .Top,
                                                        multiplier: 1,
                                                        constant: 0)
    }

    func displayHostSettings() {
        updateLogins()
        hideHostSettingsConstraint.active = false
        showHostSettingsConstraint.active = true
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
        if spotifySession != nil {
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
        if true {
            renderGuestButton("soundcloud",imageView: soundCloudImageView,infoView: soundCloudInfoView, text: "Enabled", textColor: UIColor.orangeColor())
        } else {
            renderGuestButton("soundcloud_gray",imageView: soundCloudImageView,infoView: soundCloudInfoView, text: "Disabled", textColor: UIColor.grayColor())
        }
    }

    func renderiTunesLogin() {
        iTunesInfoView.subviews.forEach() { $0.removeFromSuperview() }
        // yes, this is unnecessary, but leaving the structure for future development
        if true {
            renderGuestButton("itunes", imageView: iTunesImageView, infoView: iTunesInfoView, text: "Enabled", textColor: UIColor.redColor())
        } else {
            renderGuestButton("itunes_gray", imageView: iTunesImageView, infoView: iTunesInfoView, text: "Disabled", textColor: UIColor.grayColor())
        }
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
}
