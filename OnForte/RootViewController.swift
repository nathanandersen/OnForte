//
//  RootViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftDDP
import SwiftyJSON

/**
 RootViewController holds the root view for the application, with the
 Create and Join fields.
 */
class RootViewController: UIViewController, UITextFieldDelegate {

    var createField: UITextField!
    var joinField: UITextField!
    var createButton: UIButton! // Style.defaultButton()
    var joinButton: UIButton! // Style.defaultButton()
    var headline: UILabel!

    /**
     Clear the active fields if you touch outside the fields.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first! as UITouch
        // if outside views
        // reset
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
     Render the join text field
    */
    private func renderJoinTextField() {
        joinField = Style.defaultTextField("Playlist Code")
        joinField.layer.borderWidth = 1
        joinField.layer.borderColor = Style.primaryColor.CGColor
        joinField.layer.cornerRadius = 5
//        joinField.delegate = self
        joinField.autocapitalizationType = .None
        joinField.spellCheckingType = .No
//        joinField.returnKeyType = .Join
        joinField.textColor = Style.primaryColor

        let button = Style.defaultButton("Join")
        button.frame = CGRectMake(0, 0, 90, 50)
        button.layer.borderWidth = 0
        button.setTitle("Join",forState: .Normal)
        button.setTitleColor(Style.primaryColor, forState: .Normal)
        joinField.rightView = button
        joinField.rightViewMode = .Always

        let line = UIView(frame: CGRectMake(0,0,1,50))
        line.backgroundColor = Style.primaryColor
        joinField.rightView?.addSubview(line)
    }

    /**
     Render the create text field
    */
    private func renderCreateTextField() {
        createField = Style.defaultTextField("Playlist Name")
//        createField.delegate = self
//        createField.returnKeyType = .Go
        createField.layer.borderWidth = 1
        createField.layer.borderColor = Style.primaryColor.CGColor
        createField.layer.cornerRadius = 5
        createField.textColor = Style.primaryColor

        let button = Style.defaultButton("Join")
        button.frame = CGRectMake(0, 0, 90, 50)
        button.layer.borderWidth = 0
        button.setTitle("Create",forState: .Normal)
        button.setTitleColor(Style.primaryColor, forState: .Normal)
        createField.rightView = button
        createField.rightViewMode = .Always

        let line = UIView(frame: CGRectMake(0,0,1,50))
        line.backgroundColor = Style.primaryColor
        createField.rightView?.addSubview(line)

        createField.rightView = button
        createField.rightViewMode = .Always
    }
}
