//
//  RootViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP
import SwiftyJSON

/**
 RootViewController holds the root view for the application, with the
 Create and Join fields.
 */
class RootViewController: UIViewController, UITextFieldDelegate {

    var createSectionView: UIView!
    var joinSectionView: UIView!
    var createField: UITextField!
    var joinField: UITextField!
    var createButton: UIButton!
    var joinButton: UIButton!
    var headline: UILabel!
    var alignBottomConstraint: NSLayoutConstraint!
    var alignTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Style.whiteColor

        renderCreateSection()
        renderJoinSection()

        renderCreateTextField()
        renderJoinTextField()
        renderCreateButton()
        renderJoinButton()
        renderHeadline()

        addConstraints()

        createField.hidden = true
        joinField.hidden = true

        self.navigationItem.hidesBackButton = true
    }

    /**
     Render the create sub-section
    */
    private func renderCreateSection() {
        createSectionView = UIView()
        self.view.addSubview(createSectionView)
    }

    /**
     Render the join sub-section
    */
    private func renderJoinSection() {
        joinSectionView = UIView()
        self.view.addSubview(joinSectionView)
    }

    /**
     Clear the active fields if you touch outside the fields.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first! as UITouch
        if touch.view != createSectionView && touch.view != joinSectionView && touch.view != createButton && touch.view != joinButton {
            resetView()
        }
    }

    /**
     Clear the active fields.
    */
    private func resetView(){
        self.createField.resignFirstResponder()
        self.joinField.resignFirstResponder()

        UIView.animateWithDuration(0.25, animations: {
            self.createButton.hidden = false
            self.createField.hidden = true

            self.joinButton.hidden = false
            self.joinField.hidden = true

            self.alignTopConstraint.active = false
            self.alignBottomConstraint.active = true
            self.headline.layoutIfNeeded()
            self.createSectionView.layoutIfNeeded()
            self.joinSectionView.layoutIfNeeded()
            self.createField.text = ""
            self.joinField.text = ""

            }, completion: {
                (_) in
                self.headline.hidden = false
        })
    }

    /**
     Render the headline
    */
    private func renderHeadline(){
        headline = UILabel()
        headline.text = "Keep your playlists strong."
        headline.font = Style.defaultFont(60)
        //        headline.font = Style.headlineFont
        headline.numberOfLines = 5
        self.view.addSubview(headline)
    }

    /**
     Render the create button
    */
    private func renderCreateButton() {
        createButton = Style.defaultButton("Create a playlist")
        createSectionView.addSubview(createButton)
        createSectionView.backgroundColor = UIColor.whiteColor()
        createButton.addTarget(self, action: #selector(RootViewController.displayCreateField), forControlEvents: .TouchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = Style.constrainToBoundsOfFrame(createButton, parentView: createSectionView)
        NSLayoutConstraint.activateConstraints(constraints)
    }

    /**
     Display the create field
    */
    internal func displayCreateField() {
        UIView.animateWithDuration(0.25, animations: {
            self.alignBottomConstraint.active = false
            self.alignTopConstraint.active = true
            self.headline.layoutIfNeeded()
            self.createSectionView.layoutIfNeeded()
            self.joinSectionView.layoutIfNeeded()
            self.createButton.hidden = true
            self.createField.hidden = false
            self.joinButton.hidden = false
            self.joinField.hidden = true
            self.createField.becomeFirstResponder()

            self.headline.hidden = true

            }, completion: nil)
    }

    /**
     Display the join field
    */
    internal func displayJoinField() {
        UIView.animateWithDuration(0.25, animations: {
            self.alignBottomConstraint.active = false
            self.alignTopConstraint.active = true
            self.headline.layoutIfNeeded()
            self.createSectionView.layoutIfNeeded()
            self.joinSectionView.layoutIfNeeded()
            self.joinButton.hidden = true
            self.joinField.hidden = false
            self.createButton.hidden = false
            self.createField.hidden = true
            self.joinField.becomeFirstResponder()


            self.headline.hidden = true
            }, completion: nil)
    }

    /**
     Render the join button
    */
    private func renderJoinButton() {
        joinButton = Style.defaultButton("Join a playlist")
        joinSectionView.addSubview(joinButton)
        joinSectionView.backgroundColor = UIColor.whiteColor()
        joinButton.addTarget(self, action: #selector(RootViewController.displayJoinField), forControlEvents: .TouchUpInside)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = Style.constrainToBoundsOfFrame(joinButton, parentView: joinSectionView)
        NSLayoutConstraint.activateConstraints(constraints)
    }

    /**
     Render the join text field
    */
    private func renderJoinTextField() {
        joinField = Style.defaultTextField("Playlist Code")
        joinField.layer.borderWidth = 1
        joinField.layer.borderColor = Style.primaryColor.CGColor
        joinField.layer.cornerRadius = 5
        joinField.delegate = self
        joinField.autocapitalizationType = .None
        joinField.spellCheckingType = .No
        joinField.returnKeyType = .Join
        joinField.textColor = Style.primaryColor

        let button = Style.defaultButton("Join")
        button.frame = CGRectMake(0, 0, 90, 50)
        button.layer.borderWidth = 0
        button.setTitle("Join",forState: .Normal)
        button.setTitleColor(Style.primaryColor, forState: .Normal)
        button.addTarget(self,action: #selector(RootViewController.joinButtonPressed(_:)),forControlEvents: .TouchUpInside)
        joinField.rightView = button
        joinField.rightViewMode = .Always

        let line = UIView(frame: CGRectMake(0,0,1,50))
        line.backgroundColor = Style.primaryColor
        joinField.rightView?.addSubview(line)

        joinSectionView.addSubview(joinField)
        let constraints = Style.constrainToBoundsOfFrame(joinField, parentView: joinSectionView)
        joinField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }

    /**
     Render the create text field
    */
    private func renderCreateTextField() {
        createField = Style.defaultTextField("Playlist Name")
        createField.delegate = self
        createField.returnKeyType = .Go
        createField.layer.borderWidth = 1
        createField.layer.borderColor = Style.primaryColor.CGColor
        createField.layer.cornerRadius = 5
        createField.textColor = Style.primaryColor

        let button = Style.defaultButton("Join")
        button.frame = CGRectMake(0, 0, 90, 50)
        button.layer.borderWidth = 0
        button.setTitle("Create",forState: .Normal)
        button.setTitleColor(Style.primaryColor, forState: .Normal)
        button.addTarget(self,action: #selector(RootViewController.createButtonPressed(_:)),forControlEvents: .TouchUpInside)
        createField.rightView = button
        createField.rightViewMode = .Always

        let line = UIView(frame: CGRectMake(0,0,1,50))
        line.backgroundColor = Style.primaryColor
        createField.rightView?.addSubview(line)

        createField.rightView = button
        createField.rightViewMode = .Always

        createSectionView.addSubview(createField)
        let constraints = Style.constrainToBoundsOfFrame(createField, parentView: createSectionView)
        createField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }

    /**
     Add the constraints to the views.
    */
    private func addConstraints(){
        createSectionView.translatesAutoresizingMaskIntoConstraints = false
        joinSectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: createSectionView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0).active = true
         NSLayoutConstraint(item: createSectionView, attribute: .CenterX, relatedBy: .Equal, toItem: joinSectionView, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Height, relatedBy: .Equal, toItem: joinSectionView, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Bottom, relatedBy: .Equal, toItem: joinSectionView, attribute: .Top, multiplier: 1, constant: -15).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -5).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Right, relatedBy: .Equal, toItem: joinSectionView, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: createSectionView, attribute: .Left, relatedBy: .Equal, toItem: joinSectionView, attribute: .Left, multiplier: 1, constant: 0).active = true




        alignBottomConstraint = NSLayoutConstraint(item: joinSectionView,
                                                   attribute: .Bottom,
                                                   relatedBy: .Equal,
                                                   toItem: self.view,
                                                   attribute: .Bottom,
                                                   multiplier: 1,
                                                   constant: -15)
        alignBottomConstraint.active = true

        let navHeight = centralNavigationController.navigationBar.frame.height
        let statusHeight = UIApplication.sharedApplication().statusBarFrame.height

        alignTopConstraint = NSLayoutConstraint(item: createSectionView,
                                                attribute: .Top,
                                                relatedBy: .Equal,
                                                toItem: self.view,
                                                attribute: .Top,
                                                multiplier: 1,
                                                constant: 15 + navHeight + statusHeight)

        alignTopConstraint.active = false

        headline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headline,
                           attribute: .Bottom,
                           relatedBy: .Equal,
                           toItem: createSectionView,
                           attribute: .Top,
                           multiplier: 1,
                           constant: -15).active = true

        NSLayoutConstraint(item: headline,
                           attribute: .Left,
                           relatedBy: .Equal,
                           toItem: self.view,
                           attribute: .Left,
                           multiplier: 1,
                           constant: 15).active = true

        NSLayoutConstraint(item: headline,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: nil,
                           attribute: .NotAnAttribute,
                           multiplier: 1,
                           constant: self.view.bounds.size.width/1.5).active = true

        joinSectionView.setNeedsLayout()
        createSectionView.setNeedsLayout()
        headline.setNeedsLayout()
    }

    /**
     UITextFieldDelegate
    */
    internal func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == createField {
            self.createButtonPressed(nil)
        } else if textField == joinField {
            self.joinButtonPressed(nil)
        }
        return false
    }

    /**
     Called when the create button was pressed.
     It tries to create a playlist
    */
    internal func createButtonPressed(sender: AnyObject?){
        if let targetPlaylistName = self.createField.text {
            if targetPlaylistName != "" {
                print("title:" + targetPlaylistName)
                activityIndicator.showActivity("Creating")

                PlaylistHandler.playlistId = PlaylistHandler.generateRandomId()
                PlaylistHandler.isHost = true
                PlaylistHandler.playlistName = targetPlaylistName
                let playlistInfo = [targetPlaylistName,PlaylistHandler.playlistId]
                Meteor.call("addPlaylist",params:playlistInfo,callback:{(result: AnyObject?,error:DDPError?) in
                    if error != nil {
                        print(error)
                        exit(1)
                    } else {
                        self.parseSongAndSendToPlaylist(nil)
                    }
                })
            } else {
                let alertController = UIAlertController(title: "Sorry!", message:
                    "Please give your playlist a name.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    /**
     Called when the join button was pressed.
     Checks for existence of the playlist then joins
    */
    internal func joinButtonPressed(sender: AnyObject?) {

        activityIndicator.showActivity("Joining Playlist")
        if let targetPlaylistId = self.joinField.text?.lowercaseString {
            Meteor.call("getInitialPlaylistInfo",params:[targetPlaylistId],callback: {(result: AnyObject?,error: DDPError?) in
                if (error != nil) {
                    activityIndicator.showComplete("Failed")
                    print(error)
                    let alertController = UIAlertController(title: "Uh oh!", message:
                        "An error occurred.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                    self.presentViewController(alertController, animated: true, completion: nil)
                } else if result != nil {
                    activityIndicator.showComplete("Joined")
                    PlaylistHandler.playlistId = targetPlaylistId
                    self.parseSongAndSendToPlaylist(result!)

                } else {
                    activityIndicator.showComplete("Invalid ID")
                    print("Not valid...")
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Playlist ID was not valid.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
    }

    /**
     Join a playlist from deep-linking.
    */
    internal func joinPlaylistFromURL(targetPlaylistId: String) {
        Meteor.call("getInitialPlaylistInfo",params:[targetPlaylistId],callback: {(result: AnyObject?,error: DDPError?) in
            if (error != nil) {
                activityIndicator.showComplete("Failed")
                print(error)
                let alertController = UIAlertController(title: "Uh oh!", message:
                    "An error occurred.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                self.presentViewController(alertController, animated: true, completion: nil)
            } else if result != nil {
                activityIndicator.showComplete("Joined")
                PlaylistHandler.playlistId = targetPlaylistId
                self.parseSongAndSendToPlaylist(result!)

            } else {
                activityIndicator.showComplete("Invalid ID")
                print("Not valid...")
                let alertController = UIAlertController(title: "Sorry!", message:
                    "Playlist ID was not valid.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }

    /**
     Parse the now-playing song if joining
    */
    internal func parseSongAndSendToPlaylist(playlistInfo: AnyObject?) {
        if playlistInfo != nil {
            let jsonPlaylistInfo = JSON(playlistInfo!)
            PlaylistHandler.playlistName = jsonPlaylistInfo["name"].string!
            let songPlaying = jsonPlaylistInfo["nowPlaying"]
            if songPlaying != "" {
                let arr: [String] = songPlaying.arrayObject as! [String]
                // THIS IS NOT GOOD PRACTICE
                let title: String? = arr[1]
                let description: String? = arr[2]
                let service: Service? = Service(platform: arr[3])
                let trackId: String? = arr[4]
                let artworkURL: NSURL? = NSURL(string: arr[5])


                let song = Song(
                    title: (title != nil) ? title! : "",
                    description: (description != nil) ? description! : "",
                    service: (service != nil) ? service! : Service.Soundcloud ,
                    trackId: (trackId != nil) ? trackId! : "" ,
                    artworkURL: (artworkURL != nil) ? artworkURL : NSURL(string: "")
                )
                nowPlaying = song
            }
        }
        centralNavigationController.presentPlaylist()
    }



    
}
