//
//  HomeViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftyJSON

let nowPlayingKey = "nowPlaying"

class HomePageButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.borderColor = tintColor.CGColor
    }
}

class HomePageTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        self.layer.borderWidth = 1
        self.layer.borderColor = tintColor.CGColor
        self.layer.cornerRadius = 5


        let button = UIButton(type: .System)
        button.layer.cornerRadius = 5
        button.layer.borderColor = tintColor.CGColor
        button.tintColor = tintColor
        button.layer.borderWidth = 0
        button.frame = CGRectMake(0, 0, 90, 50) // i am hesitant about this
        self.rightView = button
        self.rightViewMode = .Always

        let line = UIView(frame: CGRectMake(0,0,1,50))
        line.backgroundColor = tintColor
        self.rightView?.addSubview(line)
    }
}

/**
 HomeViewController is the first view that a user sees when they open the application.
 */
class HomeViewController: DefaultViewController {

    enum HomeViewTextField {
        case Create
        case Join
    }

    @IBOutlet var createButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var createTextField: UITextField!
    @IBOutlet var joinTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        addLabelAndTargetToTextFieldButton(.Create)
        addLabelAndTargetToTextFieldButton(.Join)
    }

    private func addLabelAndTargetToTextFieldButton(textField: HomeViewTextField) {
        if textField == .Create {
            let button = createTextField.rightView as! UIButton
            button.setTitle("Create",forState: .Normal)
            button.addTarget(self, action: #selector(HomeViewController.handleCreateFieldSubmit), forControlEvents: .TouchUpInside)
        } else if textField == .Join {
            let button = joinTextField.rightView as! UIButton
            button.setTitle("Join",forState: .Normal)
            button.addTarget(self, action: #selector(HomeViewController.handleJoinFieldSubmit), forControlEvents: .TouchUpInside)
        } /*else {
            fatalError()
        }*/
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // register for keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)


    }

    @IBAction func userDidTap(sender: UITapGestureRecognizer) {
        if createTextField.isFirstResponder() {
            createTextField.resignFirstResponder()
        } else if joinTextField.isFirstResponder() {
            joinTextField.resignFirstResponder()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        self.view.window!.frame = UIScreen.mainScreen().bounds
        createTextField.hidden = true
        joinTextField.hidden = true
        createButton.hidden = false
        joinButton.hidden = false
    }

    @IBAction func buttonDidPress(sender: UIButton) {
        createTextField.hidden = (sender != createButton)
        joinTextField.hidden = (sender != joinButton)
        createButton.hidden = (sender == createButton)
        joinButton.hidden = (sender == joinButton)
        (sender == createButton) ? createTextField.becomeFirstResponder() : joinTextField.becomeFirstResponder()
    }
}

extension HomeViewController: UITextFieldDelegate {

    func handleJoinFieldSubmit() {
        if let targetText = joinTextField.text {
            if targetText != "" {
                joinPlaylist(targetText)
            }
        }
    }

    func joinPlaylist(targetPlaylistId: String) {
        PlaylistHandler.joinPlaylist(targetPlaylistId, completionHandler: {
            (result: Bool) in
            if result {
                (self.navigationController as! NavigationController).pushPlaylist()
            } else {
                // display some sort of error
            }

        })
    }

    func handleCreateFieldSubmit() {
        if let targetText = createTextField.text {
            if targetText != "" {
                PlaylistHandler.createPlaylist(targetText, completionHandler: {
                    (result: Bool) in
                        if result {
                            (self.navigationController as! NavigationController).pushPlaylist()
                        } else {
                            // display some sort of error
                        }
                })
            }
        }
    }


    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == joinTextField {
            handleJoinFieldSubmit()
        } else if textField == createTextField {
            handleCreateFieldSubmit()
        } else {
            fatalError()
        }
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return false
    }

    /**
     Join a playlist from deep-linking.
     */
    internal func joinPlaylistFromURL(targetPlaylistId: String) {
        joinPlaylist(targetPlaylistId)
    }

}

