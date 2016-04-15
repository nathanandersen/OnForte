//
//  PlaylistControlView.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/15/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class PlaylistControlView: UIView {

    var nowPlayingSmallView: UIView!
    var nowPlayingExpandedView: UIView!

    var topMenuBar: UIView!
    var bottomMenuBar: UIView!
    var middleContentView: UIView!

    var inviteButton: UIButton!
    var leaveButton: UIButton!
    var historyButton: UIButton!
    var searchButton: UIButton!
    var titleLabel: UILabel!
    var idLabel: UILabel!

    var middleContentHeight: CGFloat = 0


    override init(frame: CGRect) {
        super.init(frame: frame)
        print("hello, world..?")

        renderTopMenuBar()
        renderMiddleContentView()
        renderBottomMenuBar()

        addConstraints()

    }

    func renderMiddleContentView() {
        middleContentView = UIView()
        self.addSubview(middleContentView)
    }

    func collapseNowPlayingView() {
        middleContentView.subviews.forEach( {$0.removeFromSuperview()} )
        middleContentHeight = 0
        self.updateConstraints()
    }

    func showSmallNowPlayingView() {
        middleContentView.subviews.forEach( {$0.removeFromSuperview()} )
        middleContentView.addSubview(nowPlayingSmallView)
        // ^ consider how i want to actualy do this?
        middleContentHeight = 85
        self.updateConstraints()

    }

    func showLargeNowPlayingView() {
        middleContentView.subviews.forEach( {$0.removeFromSuperview()} )
        middleContentHeight = 150
        self.updateConstraints()

    }

    func renderTopMenuBar() {
        historyButton = UIButton()
        historyButton.setImage(UIImage(named: "menu-alt-256"), forState: .Normal)
        // add targets
        searchButton = UIButton()
        searchButton.setImage(UIImage(named: "search"), forState: .Normal)

        topMenuBar = renderMenuBar(playlistName, leftButton: historyButton, rightButton: searchButton)
        self.addSubview(topMenuBar)
    }

    func renderBottomMenuBar() {
        leaveButton = UIButton()
        leaveButton.setImage(UIImage(named: "delete"), forState: .Normal)
        // add target
        inviteButton = UIButton()
        inviteButton.setImage(UIImage(named: "invite"), forState: .Normal)
        // add target


        bottomMenuBar = renderMenuBar(playlistId!, leftButton: leaveButton, rightButton: inviteButton)
        self.addSubview(bottomMenuBar)
    }

    func renderMenuBar(labelTitle: String, leftButton: UIButton, rightButton: UIButton) -> UIView {
        let menuBar = UIView()
        menuBar.addSubview(leftButton)
        menuBar.addSubview(rightButton)
        let label = Style.defaultLabel()
        label.text = labelTitle
        menuBar.addSubview(label)

//        menuBar.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: leftButton, attribute: .Left, relatedBy: .Equal, toItem: menuBar, attribute: .Left, multiplier: 1, constant: 10).active = true
        NSLayoutConstraint(item: rightButton, attribute: .Right, relatedBy: .Equal, toItem: menuBar, attribute: .Right, multiplier: 1, constant: -10).active = true
        NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: menuBar, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: leftButton, attribute: .CenterY, relatedBy: .Equal, toItem: menuBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: menuBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: rightButton, attribute: .CenterY, relatedBy: .Equal, toItem: menuBar, attribute: .CenterY, multiplier: 1, constant: 0).active = true

        NSLayoutConstraint(item: leftButton, attribute: .Height, relatedBy: .Equal, toItem: rightButton, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: rightButton, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: rightButton, attribute: .Height, relatedBy: .Equal, toItem: menuBar, attribute: .Height, multiplier: 1, constant: -5).active = true
        // ^ this one sets the margins



        leftButton.updateConstraints()
        rightButton.updateConstraints()
        label.updateConstraints()
        return menuBar
    }

    func addConstraints() {
        topMenuBar.translatesAutoresizingMaskIntoConstraints = false
        middleContentView.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: topMenuBar, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomMenuBar, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomMenuBar, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomMenuBar, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Height, relatedBy: .Equal, toItem: bottomMenuBar, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25).active = true

        NSLayoutConstraint(item: middleContentView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: middleContentView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: middleContentView, attribute: .Top, relatedBy: .Equal, toItem: topMenuBar, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: middleContentView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomMenuBar, attribute: .Top, multiplier: 1, constant: 0).active = true

        NSLayoutConstraint(item: middleContentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: middleContentHeight).active = true




        topMenuBar.updateConstraints()
        middleContentView.updateConstraints()
        bottomMenuBar.updateConstraints()
    }



    
    required init?(coder aDecoder: NSCoder) {
        fatalError("PlaylistControlView does not support NSCoding")
    }



}