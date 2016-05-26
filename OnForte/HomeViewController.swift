//
//  HomeViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import SwiftyJSON

class HomeViewController: HiddenBackButtonViewController {

    @IBOutlet var createButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var createTextField: UITextField!
    @IBOutlet var joinTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // register for keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // unregister from keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWasShown(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.window!.frame.origin.y = -1 * keyboardSize.height
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        print("hiding..")
        self.view.window!.frame = UIScreen.mainScreen().bounds
        createTextField.hidden = true
        joinTextField.hidden = true
        createButton.hidden = false
        joinButton.hidden = false
    }

    @IBAction func buttonDidPress(sender: UIButton) {
        print("hello, world")
        createTextField.hidden = (sender != createButton)
        joinTextField.hidden = (sender != joinButton)
        createButton.hidden = (sender == createButton)
        joinButton.hidden = (sender == joinButton)
        (sender == createButton) ? createTextField.becomeFirstResponder() : joinTextField.becomeFirstResponder()
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let targetText = textField.text {
            if targetText != "" {
                if textField == joinTextField {
                    PlaylistHandler.joinPlaylist(targetText, completionHandler: {
                        (success: Bool, result: AnyObject?) in
                        if success {
                            if let data = result {
                                self.parseSongAndSendToPlaylist(data)
                            } else {
                                // invalid ID
                            }
                        } else {
                            // a Meteor error occurred
                        }
                    })
                } else if textField == createTextField {
                    PlaylistHandler.createPlaylist(targetText) {
                        (success: Bool) in
                        if success {
                            self.parseSongAndSendToPlaylist(nil)
                        } else {
                            print("it failed")
                            // handle the error
                        }
                    }
                }
            }
        }

        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
                PlaylistHandler.nowPlaying = song
            }
        }
        appNavigationController.pushPlaylist()
    }
}

