//
//  Style.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import BFPaperButton

/**
 Style encapsulates the global style of the app
 */
struct Style {

    //http://sdbr.net/post/Themes-in-Swift/
    // declare all fonts, colors, etc as static variables so we
    // can access them anywhere in the project

    // time to start standardizing fonts.

    static var menuButtonInset: CGFloat = 15

    static var darkGrayColor = UIColor(
        red: 147.0 / 255.0,
        green: 149.0 / 255.0,
        blue: 152.0 / 250.0,
        alpha: 1
    )
    
    static var blackColor = UIColor.blackColor()
    static var clearColor = UIColor.clearColor()
    static var grayColor = UIColor.grayColor()
    static var translucentColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)
    static var whiteColor = UIColor.whiteColor()
    static var greenColor = UIColor.greenColor()
    static var yellowColor = UIColor.yellowColor()
    static var orangeColor = UIColor.orangeColor()
    static var redColor = UIColor.redColor()
    static var lightGrayColor = UIColor.lightGrayColor()

    static var primaryBlue = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)
    static var secondaryBlue = UIColor(red:0.00, green:0.45, blue:0.74, alpha:0.5)

    static var spotifyGreen = UIColor(red:0.14, green:0.81, blue:0.37, alpha:1.0)
    // #23CF5F
//    static var soundcloudOrange = UIColor(red: 255, green: 119, blue: 0, alpha: 1)
    
    static var primaryColor = primaryBlue
    static var secondaryColor = secondaryBlue

    static var logoFont = UIFont(name: "Raleway-Thin", size: 30.0)
    static var headlineFont = UIFont(name: "Raleway-Medium", size: 60.0)
    static var textColor = UIColor.blackColor()

    static func defaultFont(fontsize: CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(fontsize)
    }

    static func defaultButton(title: String) -> UIButton {
        let button = UIButton(type: .System)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = Style.primaryColor.CGColor
        button.backgroundColor = Style.whiteColor
        button.setTitle(title, forState: .Normal)
        button.tintColor = Style.primaryColor
        button.titleLabel?.font = Style.defaultFont(15)
        return button
    }

    static func iconButton() -> UIButton {
        let button = UIButton(type: .System)
        button.backgroundColor = UIColor.clearColor()
        button.tintColor = Style.primaryColor
        button.adjustsImageWhenHighlighted = true
        return button
    }

    static func defaultTextField(title: String) -> UITextField {
        let field = UITextField()
        field.placeholder = title
        field.clearButtonMode = .WhileEditing
        field.borderStyle = .RoundedRect
        field.autocorrectionType = .No
        return field
    }

    static func defaultLabel() -> UILabel {
        let label = UILabel()
        label.font = Style.defaultFont(15)
        label.textColor = Style.textColor
        label.adjustsFontSizeToFitWidth = false
        label.allowsDefaultTighteningForTruncation = true
        label.textAlignment = .Center
        label.userInteractionEnabled = false
        return label
    }

    static func constrainToBoundsOfFrame(label: UIView, parentView: UIView) -> [NSLayoutConstraint] {
        let leftConstraint =
            NSLayoutConstraint(item: label,
                               attribute: .LeadingMargin,
                               relatedBy: .Equal,
                               toItem: parentView,
                               attribute: .LeadingMargin,
                               multiplier: 1,
                               constant: 0)
        let rightConstraint =
            NSLayoutConstraint(item: label,
                               attribute: .TrailingMargin,
                               relatedBy: .Equal,
                               toItem: parentView,
                               attribute: .TrailingMargin,
                               multiplier: 1,
                               constant: 0)
        let topConstraint =
            NSLayoutConstraint(item: label,
                               attribute: .Top,
                               relatedBy: .Equal,
                               toItem: parentView,
                               attribute: .Top,
                               multiplier: 1,
                               constant: 0)
        let bottomConstraint =
            NSLayoutConstraint(item: label,
                               attribute: .Bottom,
                               relatedBy: .Equal,
                               toItem: parentView,
                               attribute: .Bottom,
                               multiplier: 1,
                               constant: 0)
        return [leftConstraint,rightConstraint,topConstraint,bottomConstraint]
    }
}