//
//  Style.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

/**
 Style encapsulates the global style of the app
 */
struct Style {

    //http://sdbr.net/post/Themes-in-Swift/
    // declare all fonts, colors, etc as static variables so we
    // can access them anywhere in the project

    static var darkGrayColor = UIColor(
        red: 147.0 / 255.0,
        green: 149.0 / 255.0,
        blue: 152.0 / 250.0,
        alpha: 1
    )

    static var primaryBlue = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)

    static var spotifyGreen = UIColor(red:0.14, green:0.81, blue:0.37, alpha:1.0)
    // #23CF5F
    static var soundcloudOrange = UIColor.orangeColor()
    static var itunesRed = UIColor.redColor()


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