//
//  Style.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import BFPaperButton


struct Style {

    //http://sdbr.net/post/Themes-in-Swift/
    // declare all fonts, colors, etc as static variables so we
    // can access them anywhere in the project

    // time to start standardizing fonts.

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
    static var primaryRed = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
    static var secondaryRed = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
    static var primaryGreen = UIColor(red: 0, green: 1.0, blue: 0, alpha: 1.0)
    static var secondaryGreen = UIColor(red: 0, green: 1.0, blue: 0, alpha: 0.5)
    static var primaryPurple = UIColor(red: 1.0, green: 0, blue: 1.0, alpha: 1.0)
    static var secondaryPurple = UIColor(red: 1.0, green: 0, blue: 1.0, alpha: 0.5)
    static var primaryYellow = UIColor(red: 1.0, green: 1.0, blue: 0, alpha: 1.0)
    static var secondaryYellow = UIColor(red: 1.0, green: 1.0, blue: 0, alpha: 0.5)
    static var primaryOrange = UIColor(red: 1.0, green: 0.5, blue: 0, alpha: 1.0)
    static var secondaryOrange = UIColor(red: 1.0, green: 0.5, blue: 0, alpha: 0.5)

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

    static func themeBlue() {
        primaryColor = primaryBlue
        secondaryColor = secondaryBlue
    }

    static func themeRed() {
        primaryColor = primaryRed
        secondaryColor = secondaryRed
    }

    static func themeGreen() {
        primaryColor = primaryGreen
        secondaryColor = secondaryGreen
    }

    static func themeYellow() {
        primaryColor = primaryYellow
        secondaryColor = secondaryYellow
    }

    static func themePurple() {
        primaryColor = primaryPurple
        secondaryColor = secondaryPurple
    }

    static func themeOrange() {
        primaryColor = primaryOrange
        secondaryColor = secondaryOrange
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
        //        button.titleLabel?.font = Style.buttonFont
        return button
    }

    static func defaultBFPaperButton(title: String) -> BFPaperButton {
        let button = BFPaperButton()
        button.isRaised = false
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = Style.primaryColor.CGColor
        button.tapCircleColor = Style.secondaryColor
        button.backgroundColor = Style.whiteColor
        button.setTitle(title, forState: .Normal)
        button.tintColor = Style.primaryColor
        button.titleLabel?.font = Style.defaultFont(20)
        //        button.titleLabel?.font = Style.buttonFont
        button.setTitleColor(Style.primaryColor, forState: .Normal)
        button.titleFont = Style.defaultFont(17)
        //        button.titleFont = UIFont(name: "Raleway-Medium", size: 17.0)
        return button
    }

    static func circularButton(fontSize: Double) -> BFPaperButton {
        let button = BFPaperButton()
        button.tapCircleDiameter = 50.0
        button.backgroundColor = UIColor.whiteColor()
        button.tapCircleColor = Style.secondaryColor
        button.rippleBeyondBounds = false
        button.setTitleColor(Style.primaryColor, forState: .Normal)
        button.titleFont = UIFont.systemFontOfSize(CGFloat(fontSize))
        //        button.titleFont = UIFont(name: font, size: CGFloat(fontSize))
        button.rippleFromTapLocation = false
        button.tintColor = Style.primaryColor
        button.cornerRadius = 25
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = Style.primaryColor.CGColor
        button.isRaised = true
        button.liftedShadowRadius = 25.0
        return button
    }

    static func invisibleButton() -> BFPaperButton {
        let button = BFPaperButton()
        button.backgroundColor = UIColor.clearColor()
        button.isRaised = false
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

    static func constrainToHeightOfFrame(label: UIView, parentView: UIView) -> [NSLayoutConstraint] {
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
        return [topConstraint,bottomConstraint]
    }
}


class ShadowButton: UIButton {
    func setupView() {
        self.layer.shadowColor = Style.blackColor.CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1
        self.layer.shadowOffset = CGSizeMake(2.0, 2.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported for ShadowButon")
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.contentEdgeInsets = UIEdgeInsetsMake(1, 1, -1, -1)
        self.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        self.layer.shadowOpacity = 0.8
        super.touchesBegan(touches, withEvent: event)
    }
/*
 -(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 self.contentEdgeInsets = UIEdgeInsetsMake(1.0,1.0,-1.0,-1.0);
 self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
 self.layer.shadowOpacity = 0.8;

 [super touchesBegan:touches withEvent:event];

 }*/

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        self.layer.shadowOpacity = 0.5
        super.touchesEnded(touches, withEvent: event)
    }
/*
 -(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
 self.contentEdgeInsets = UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
 self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
 self.layer.shadowOpacity = 0.5;

 [super touchesEnded:touches withEvent:event];

 }*/


}