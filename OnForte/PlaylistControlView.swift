//
//  PlaylistControlView.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/15/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class PlaylistControlView: UIView {


    var topMenuBar: UIView!
    var bottomMenuBar: UIView!
    var musicPlayerView: MusicPlayerView!

    var inviteButton: UIButton!
    var leaveButton: UIButton!
    var historyButton: UIButton!
    var searchButton: UIButton!
    var titleLabel: UILabel!
    var idLabel: UILabel!

    var middleContentHeight: CGFloat = 1


    override init(frame: CGRect) {
        super.init(frame: frame)
        print("hello, world..?")

        renderTopMenuBar()
        renderMusicPlayerView()
        renderBottomMenuBar()

        addConstraints()
        self.collapseNowPlayingView()
    }

    func renderMusicPlayerView() {
        musicPlayerView = MusicPlayerView()
        self.addSubview(musicPlayerView)
    }

    func collapseNowPlayingView() {
        musicPlayerView.collapse()
        middleContentHeight = 0
        // ^ ?
        self.updateConstraints()
    }

    func showSmallNowPlayingView() {
        musicPlayerView.showSmall()
        // ^ consider how i want to actualy do this?
        middleContentHeight = 85
        self.updateConstraints()

    }

    func showLargeNowPlayingView() {
        musicPlayerView.showLarge()
        middleContentHeight = 150
        self.updateConstraints()

    }

    func renderTopMenuBar() {
        historyButton = Style.iconButton()
        historyButton.setImage(UIImage(named: "menu-alt-256")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        historyButton.imageEdgeInsets = UIEdgeInsetsMake(5, 3, 5, 3)
        historyButton.addTarget(self, action: #selector(PlaylistControlView.historyButtonPressed), forControlEvents: .TouchUpInside)
        searchButton = Style.iconButton()
        searchButton.setImage(UIImage(named: "search")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(5, 3, 5, 3)
        searchButton.addTarget(self, action: #selector(PlaylistControlView.searchButtonPressed), forControlEvents: .TouchUpInside)

//        historyButton = UIButton()
//        historyButton.setImage(UIImage(named: "menu-alt-256"), forState: .Normal)
        // add targets
//        searchButton = UIButton()
//        searchButton.setImage(UIImage(named: "search"), forState: .Normal)

        topMenuBar = renderMenuBar(playlistName, leftButton: historyButton, rightButton: searchButton)
        self.addSubview(topMenuBar)
    }

    func historyButtonPressed() {
        print("menu button pressed")
    }

    func searchButtonPressed() {
        print("search button pressed")
    }

    func renderBottomMenuBar() {
        inviteButton = Style.iconButton()
        inviteButton.setImage(UIImage(named: "invite")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        inviteButton.imageEdgeInsets = UIEdgeInsetsMake(5, 3, 5, 3)
        inviteButton.addTarget(self, action: #selector(PlaylistControlView.inviteButtonPressed), forControlEvents: .TouchUpInside)
        leaveButton = Style.iconButton()
        leaveButton.setImage(UIImage(named: "delete")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        leaveButton.imageEdgeInsets = UIEdgeInsetsMake(5, 3, 5, 3)
        leaveButton.addTarget(self, action: #selector(PlaylistControlView.leaveButtonPressed), forControlEvents: .TouchUpInside)
        bottomMenuBar = renderMenuBar(playlistId!, leftButton: leaveButton, rightButton: inviteButton)
        self.addSubview(bottomMenuBar)
    }

    func leaveButtonPressed() {
        print("leave button pressed")
    }

    func inviteButtonPressed() {
        print("hello invite")
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
        NSLayoutConstraint(item: leftButton, attribute: .Height, relatedBy: .Equal, toItem: leftButton, attribute: .Width, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: rightButton, attribute: .Height, relatedBy: .Equal, toItem: rightButton, attribute: .Width, multiplier: 1, constant: 0).active = true


        // ^ this one sets the margins



        leftButton.updateConstraints()
        rightButton.updateConstraints()
        label.updateConstraints()
        return menuBar
    }

    func addConstraints() {
        topMenuBar.translatesAutoresizingMaskIntoConstraints = false
        musicPlayerView.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: topMenuBar, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomMenuBar, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomMenuBar, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: bottomMenuBar, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Height, relatedBy: .Equal, toItem: bottomMenuBar, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: topMenuBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25).active = true

        NSLayoutConstraint(item: musicPlayerView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: musicPlayerView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: musicPlayerView, attribute: .Top, relatedBy: .Equal, toItem: topMenuBar, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: musicPlayerView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomMenuBar, attribute: .Top, multiplier: 1, constant: 0).active = true

        NSLayoutConstraint(item: musicPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: middleContentHeight).active = true




        topMenuBar.updateConstraints()
        musicPlayerView.updateConstraints()
        bottomMenuBar.updateConstraints()
    }



    
    required init?(coder aDecoder: NSCoder) {
        fatalError("PlaylistControlView does not support NSCoding")
    }



}