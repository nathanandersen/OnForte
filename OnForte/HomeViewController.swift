//
//  HomeViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

//let nowPlayingKey = "nowPlaying"

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

    var createTextFieldRightButton: UIButton!
    var joinTextFieldRightButton: UIButton!

    var isWaitingForServerResponse = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addLabelAndTargetToTextFieldButton(.Create)
        addLabelAndTargetToTextFieldButton(.Join)
    }

    private func addLabelAndTargetToTextFieldButton(textField: HomeViewTextField) {
        if textField == .Create {
            createTextFieldRightButton = createTextField.rightView as! UIButton
            createTextFieldRightButton.setTitle("Create",forState: .Normal)
            createTextFieldRightButton.addTarget(self, action: #selector(HomeViewController.handleCreateFieldSubmit), forControlEvents: .TouchUpInside)
        } else if textField == .Join {
            joinTextFieldRightButton = joinTextField.rightView as! UIButton
            joinTextFieldRightButton.setTitle("Join",forState: .Normal)
            joinTextFieldRightButton.addTarget(self, action: #selector(HomeViewController.handleJoinFieldSubmit), forControlEvents: .TouchUpInside)
        }
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

        createTextFieldRightButton.backgroundColor = UIColor.whiteColor()
        createTextFieldRightButton.tintColor = Style.primaryBlue
        joinTextFieldRightButton.backgroundColor = UIColor.whiteColor()
        joinTextFieldRightButton.tintColor = Style.primaryBlue

    }

    @IBAction func buttonDidPress(sender: UIButton) {
        createTextField.hidden = (sender != createButton)
        joinTextField.hidden = (sender != joinButton)
        createButton.hidden = (sender == createButton)
        joinButton.hidden = (sender == joinButton)
        (sender == createButton) ?
            createTextField.becomeFirstResponder() :
            joinTextField.becomeFirstResponder()
    }
}

extension HomeViewController: UITextFieldDelegate {

    func joinPlaylist(targetPlaylistId: String) {
        isWaitingForServerResponse = true
        PlaylistHandler.joinPlaylist(targetPlaylistId, completionHandler: {
            (result: Bool) in
            self.joinTextField.resignFirstResponder()
            self.isWaitingForServerResponse = false
            (result) ?
                (self.navigationController as! NavigationController).pushPlaylist() :
                () // display an error

        })
    }

    func handleCreateFieldSubmit() {
        if !isWaitingForServerResponse {
            if let targetText = createTextField.text {

                createTextFieldRightButton.backgroundColor = Style.primaryBlue
                createTextFieldRightButton.tintColor = UIColor.whiteColor()

                if targetText != "" {
                    isWaitingForServerResponse = true
                    PlaylistHandler.createPlaylist(targetText, completionHandler: {
                        (result: Bool) in
                        self.createTextField.resignFirstResponder()
                        self.isWaitingForServerResponse = false

                        (result) ?
                            (self.navigationController as! NavigationController).pushPlaylist() :
                            () // error function
                    })
                }
            }
        }
    }

    func handleJoinFieldSubmit() {
        if !isWaitingForServerResponse {
            if let targetText = joinTextField.text {

                joinTextFieldRightButton.backgroundColor = Style.primaryBlue
                joinTextFieldRightButton.tintColor = UIColor.whiteColor()

                (targetText != "") ?
                    joinPlaylist(targetText) : ()
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        (textField == joinTextField) ?
            handleJoinFieldSubmit() :
            handleCreateFieldSubmit()

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

