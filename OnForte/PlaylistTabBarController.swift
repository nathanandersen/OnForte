//
//  PlaylistTabBarController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/28/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import MessageUI

let hostTimerInterval: NSTimeInterval = 30
let updatePlaylistKey = "updatePlaylist"

class PlaylistTabBarController: UITabBarController {
    
    let leaveAlertTitle = "Leave Playlist"
    let leaveMessage = "Are you sure you want to leave this playlist?"
    private var alertController: UIAlertController?
    private var iMessageController: MFMessageComposeViewController?

    private var hostTimer: NSTimer = NSTimer()


    @IBOutlet var bottomTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        displayViewController(PlaylistViewController)
    }

    @IBAction func inviteButtonDidPress(sender: UIBarButtonItem) {
        sendInvitations()
    }
    @IBAction func settingsButtonDidPress(sender: UIBarButtonItem) {
        (navigationController as! NavigationController).pushSettings()
    }
    @IBAction func leaveButtonDidPress(sender: UIBarButtonItem) {
        if alertController == nil {
            alertController = UIAlertController(title: leaveAlertTitle, message: leaveMessage, preferredStyle: .Alert)
            alertController?.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

            alertController?.addAction(UIAlertAction(title: "Leave", style: .Destructive, handler: {
                _ in
                if PlaylistHandler.isHost() {
                    self.hostTimer.invalidate()
                }
                PlaylistHandler.leavePlaylist()
                (self.navigationController as? NavigationController)?.popPlaylist()
            }))
        }
        selectedViewController?.presentViewController(alertController!, animated: true, completion: nil)
    }

    internal func updatePlaylist() {
        print("updating...")
        //        print("host updating")
        APIHandler.updateAPIInformation()
        hostTimer.invalidate()
        hostTimer = NSTimer.scheduledTimerWithTimeInterval(hostTimerInterval, target: self, selector: #selector(PlaylistTabBarController.updatePlaylist), userInfo: nil, repeats: true)
    }

    /**
     Display a view controller of type T
    */
    internal func displayViewController<T>(type: T.Type) {
        // Guarantee that it is one of 3 acceptable types
        guard (T.self == PlaylistViewController.self) || (T.self == HistoryViewController.self) || (T.self == MusicSearchViewController.self) else {
            fatalError()
        }

        for i in 0..<self.viewControllers!.count {
            if let _ = self.viewControllers?[i] as? T {
                self.selectedIndex = i
                return
            }
        }
    }

    internal func presentNewPlaylist() {
        if PlaylistHandler.isHost() {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistTabBarController.updatePlaylist), name: updatePlaylistKey, object: nil)
            updatePlaylist()
        }
        self.title = PlaylistHandler.playlist!.playlistId

        self.viewControllers?.forEach({
            // if loaded, reset both the PVC and HVC
            if let pvc = $0 as? PlaylistViewController {
                if pvc.isViewLoaded() {
                    pvc.presentNewPlaylist()
                }
            } else if let hvc = $0 as? HistoryViewController {
                if hvc.isViewLoaded() {
                    hvc.presentNewPlaylist()
                }
            }
        })
    }

}

extension PlaylistTabBarController: MFMessageComposeViewControllerDelegate {
    internal func sendInvitations() {
        if MFMessageComposeViewController.canSendText() {
            if iMessageController == nil {
                iMessageController = MFMessageComposeViewController()
                iMessageController!.messageComposeDelegate = self
                iMessageController!.body = "You've been invited to join a playlist on OnForte at OnForte://" + PlaylistHandler.playlist!.playlistId + ". Don't have the app? Join the fun at www.onforte.com/" + PlaylistHandler.playlist!.playlistId + " ."
            }
            iMessageController!.recipients = nil
            selectedViewController?.presentViewController(iMessageController!, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "iMessage unavailable", message: "We're sorry, iMessage seems to be unavailable at the moment. Try again later?", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            selectedViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        print("some sort of result happened")
        // this hasn't been debugged yet
        if result == MessageComposeResultFailed {
            // alert the user that it failed
            let alertController = UIAlertController(title: "Message failed", message: "We're sorry, iMessage did not deliver your messages. Try again?", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        }
        presentedViewController!.dismissViewControllerAnimated(true, completion: nil)
    }

}