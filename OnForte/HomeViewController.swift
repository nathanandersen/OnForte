//
//  HomeViewController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class HomeViewController: HiddenBackButtonViewController {

    @IBOutlet var createButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var createTextField: UITextField!
    @IBOutlet var joinTextField: UITextField!

    @IBAction func createButtonDidPress(sender: AnyObject) {
        createTextField.becomeFirstResponder()
    }

    @IBAction func joinButtonDidPress(sender: AnyObject) {
        joinTextField.becomeFirstResponder()
    }
}