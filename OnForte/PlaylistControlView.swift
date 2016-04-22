//
//  PlaylistControlView.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/15/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import MMDrawerController


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

    var playlistController: PlaylistController!

    var collapseMusicPlayerConstraint: NSLayoutConstraint!
    var smallMusicPlayerConstraint: NSLayoutConstraint!
    var startMusicPlayerConstraint: NSLayoutConstraint!
    var largeMusicPlayerConstraint: NSLayoutConstraint!


    override init(frame: CGRect) {
        super.init(frame: frame)
        renderTopMenuBar()
        renderMusicPlayerView()
        renderBottomMenuBar()

        addConstraints()
        self.collapseNowPlayingView()
        self.backgroundColor = Style.translucentColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    func setParentPlaylistController(playlistC: PlaylistController) {
        self.playlistController = playlistC
        musicPlayerView.setParentPlaylistController(playlistC)
    }

    func renderMusicPlayerView() {
        musicPlayerView = MusicPlayerView()
        self.addSubview(musicPlayerView)
    }

    func collapseNowPlayingView() {
        if musicPlayerView.displayType == .None {
            return
        }

        musicPlayerView.collapse()
        smallMusicPlayerConstraint.active = false
        largeMusicPlayerConstraint.active = false
        startMusicPlayerConstraint.active = false
        collapseMusicPlayerConstraint.active = true
        musicPlayerView.updateConstraints()
    }

    func showANowPlayingView() {
        if musicPlayerView.displayType == .None || musicPlayerView.displayType == .Start {
            self.showSmallNowPlayingView()
        }
    }

    func showSmallNowPlayingView() {
        if musicPlayerView.displayType == .Small {
            return
        }
        musicPlayerView.showSmall()
        collapseMusicPlayerConstraint.active = false
        largeMusicPlayerConstraint.active = false
        startMusicPlayerConstraint.active = false
        smallMusicPlayerConstraint.active = true
        musicPlayerView.updateConstraints()
    }

    func showStartMusicPlayer() {
        if musicPlayerView.displayType == .Start {
            return
        }
        musicPlayerView.showStart()
        collapseMusicPlayerConstraint.active = false
        smallMusicPlayerConstraint.active = false
        largeMusicPlayerConstraint.active = false
        startMusicPlayerConstraint.active = true
        musicPlayerView.updateConstraints()

    }

    func showLargeNowPlayingView() {
        if musicPlayerView.displayType == .Large {
            return
        }
        musicPlayerView.showLarge()
        collapseMusicPlayerConstraint.active = false
        smallMusicPlayerConstraint.active = false
        startMusicPlayerConstraint.active = false
        largeMusicPlayerConstraint.active = true
        musicPlayerView.updateConstraints()
    }

    func renderTopMenuBar() {
        historyButton = Style.iconButton()
        historyButton.setImage(UIImage(named: "menu-alt-256")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        historyButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        historyButton.addTarget(self, action: #selector(PlaylistControlView.historyButtonPressed), forControlEvents: .TouchUpInside)
        searchButton = Style.iconButton()
        searchButton.setImage(UIImage(named: "search")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        searchButton.addTarget(self, action: #selector(PlaylistControlView.searchButtonPressed), forControlEvents: .TouchUpInside)

        topMenuBar = renderMenuBar(playlistName, leftButton: historyButton, rightButton: searchButton)
        self.addSubview(topMenuBar)
    }

    func historyButtonPressed() {
        playlistController.mm_drawerController.openDrawerSide(.Left, animated: true, completion: nil)
    }

    func searchButtonPressed() {
        playlistController.mm_drawerController.openDrawerSide(.Right, animated: true, completion: nil)
        // activate search?
    }

    func renderBottomMenuBar() {
        inviteButton = Style.iconButton()
        inviteButton.setImage(UIImage(named: "invite")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        inviteButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        inviteButton.addTarget(self, action: #selector(PlaylistControlView.inviteButtonPressed), forControlEvents: .TouchUpInside)
        leaveButton = Style.iconButton()
        leaveButton.setImage(UIImage(named: "delete")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        leaveButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        leaveButton.addTarget(self, action: #selector(PlaylistControlView.leaveButtonPressed), forControlEvents: .TouchUpInside)
        bottomMenuBar = renderMenuBar(playlistId!, leftButton: leaveButton, rightButton: inviteButton)
        self.addSubview(bottomMenuBar)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlaylistControlView.togglePlayerDisplaySize))
        tapGestureRecognizer.numberOfTapsRequired = 2
        musicPlayerView.addGestureRecognizer(tapGestureRecognizer)
    }

    func togglePlayerDisplaySize() {
        if musicPlayerView.displayType == .Large {
            self.showSmallNowPlayingView()
        } else if musicPlayerView.displayType == .Small {
            self.showLargeNowPlayingView()
        }
    }

    func leaveButtonPressed() {
//        print("leave button pressed")
        NSNotificationCenter.defaultCenter().postNotificationName("leavePlaylist", object: nil)
//        self.showLargeNowPlayingView()
        // maybe we should re-render images
    }

    func inviteButtonPressed() {
//        print("hello invite")
        playlistController.inviteButtonPressed()
//        self.showSmallNowPlayingView()
        // maybe we should re-render images
    }

    func renderMenuBar(labelTitle: String, leftButton: UIButton, rightButton: UIButton) -> UIView {
        let menuBar = UIView()
        menuBar.addSubview(leftButton)
        menuBar.addSubview(rightButton)
        let label = Style.defaultLabel()
        label.text = labelTitle
        menuBar.addSubview(label)

        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        let leftButtonLeading = NSLayoutConstraint(item: leftButton, attribute: .Leading, relatedBy: .Equal, toItem: menuBar, attribute: .Leading, multiplier: 1, constant: 10)
        leftButtonLeading.active = true
        leftButtonLeading.identifier = "Left Button Leading"
        let leftButtonTrailing = NSLayoutConstraint(item: rightButton, attribute: .Trailing, relatedBy: .Equal, toItem: menuBar, attribute: .Trailing, multiplier: 1, constant: -10)
        leftButtonTrailing.active = true
        leftButtonTrailing.identifier = "Left Button Trailing"
        let labelCenterX = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: menuBar, attribute: .CenterX, multiplier: 1, constant: 0)
        labelCenterX.active = true
        labelCenterX.identifier = "Label Center X"
        let labelLeftCenterY = NSLayoutConstraint(item: leftButton, attribute: .CenterY, relatedBy: .Equal, toItem: menuBar, attribute: .CenterY, multiplier: 1, constant: 0)
        labelLeftCenterY.active = true
        labelLeftCenterY.identifier = "left button label Center Y"
        let labelCenterY = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: menuBar, attribute: .CenterY, multiplier: 1, constant: 0)
        labelCenterY.active = true
        labelCenterY.identifier = "Label center y"
        let labelRightCenterY = NSLayoutConstraint(item: rightButton, attribute: .CenterY, relatedBy: .Equal, toItem: menuBar, attribute: .CenterY, multiplier: 1, constant: 0)
        labelRightCenterY.active = true
        labelRightCenterY.identifier = "Label right center y"

        let buttonEqualHeights = NSLayoutConstraint(item: leftButton, attribute: .Height, relatedBy: .Equal, toItem: rightButton, attribute: .Height, multiplier: 1, constant: 0)
        buttonEqualHeights.active = true
        buttonEqualHeights.identifier = "Button equal heights"
        let labelEqualHeight = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: rightButton, attribute: .Height, multiplier: 1, constant: 0)
        labelEqualHeight.active = true
        labelEqualHeight.identifier = "Label equal to button height"
        let buttonHeight = NSLayoutConstraint(item: rightButton, attribute: .Height, relatedBy: .Equal, toItem: menuBar, attribute: .Height, multiplier: 1, constant: -5)
        buttonHeight.active = true
        buttonHeight.identifier = "Button height to bar"
        let lbaspectRatio = NSLayoutConstraint(item: leftButton, attribute: .Height, relatedBy: .Equal, toItem: leftButton, attribute: .Width, multiplier: 1, constant: 0)
        lbaspectRatio.active = true
        lbaspectRatio.identifier = "Left button aspect ratio"
        let rbaspectRatio = NSLayoutConstraint(item: rightButton, attribute: .Height, relatedBy: .Equal, toItem: rightButton, attribute: .Width, multiplier: 1, constant: 0)
        rbaspectRatio.active = true
        rbaspectRatio.identifier = "Right button aspect ratio"



        leftButton.updateConstraints()
        rightButton.updateConstraints()
        label.updateConstraints()
        return menuBar
    }

    func addConstraints() {
        topMenuBar.translatesAutoresizingMaskIntoConstraints = false
        musicPlayerView.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuBar.translatesAutoresizingMaskIntoConstraints = false

        let menuBarHeight: CGFloat = 35

        let topMenuBarLeading = NSLayoutConstraint(item: topMenuBar, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        topMenuBarLeading.active = true
        topMenuBarLeading.identifier = "Top Menu Bar Leading"
        let topMenuBarTrailing = NSLayoutConstraint(item: topMenuBar, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        topMenuBarTrailing.active = true
        topMenuBarTrailing.identifier = "Top Menu Bar Trailing"
        let bottomMenuBarLeading = NSLayoutConstraint(item: bottomMenuBar, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        bottomMenuBarLeading.active = true
        bottomMenuBarLeading.identifier = "Bottom Menu bar Leading"
        let bottomMenuBarTrailing = NSLayoutConstraint(item: bottomMenuBar, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        bottomMenuBarTrailing.active = true
        bottomMenuBarTrailing.identifier = "Bottom menu bar Trailing"
        let topMenuBarTop = NSLayoutConstraint(item: topMenuBar, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        topMenuBarTop.active = true
        topMenuBarTop.identifier = "Top Menu Bar Top"
        let bottomMenuBarBottom = NSLayoutConstraint(item: bottomMenuBar, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        bottomMenuBarBottom.active = true
        bottomMenuBarBottom.identifier = "Bottom menu bar bottom"
        let menuBarEqualHeight = NSLayoutConstraint(item: topMenuBar, attribute: .Height, relatedBy: .Equal, toItem: bottomMenuBar, attribute: .Height, multiplier: 1, constant: 0)
        menuBarEqualHeight.active = true
        menuBarEqualHeight.identifier = "Menu bar Equal height"
        let menuBarHeightConstant = NSLayoutConstraint(item: topMenuBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: menuBarHeight)
        menuBarHeightConstant.active = true
        menuBarHeightConstant.identifier = "Menu bar height constant"

        let musicPlayerLeading = NSLayoutConstraint(item: musicPlayerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        musicPlayerLeading.active = true
        musicPlayerLeading.identifier = "Music Player Leading"
        let musicPlayerTrailing = NSLayoutConstraint(item: musicPlayerView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        musicPlayerTrailing.active = true
        musicPlayerTrailing.identifier = "Music Player Trailing"
        let musicPlayerTop = NSLayoutConstraint(item: musicPlayerView, attribute: .Top, relatedBy: .Equal, toItem: topMenuBar, attribute: .Bottom, multiplier: 1, constant: 0)
        musicPlayerTop.active = true
        musicPlayerTop.identifier = "Music player top"
        let musicPlayerBottom = NSLayoutConstraint(item: musicPlayerView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomMenuBar, attribute: .Top, multiplier: 1, constant: 0)
        musicPlayerBottom.active = true
        musicPlayerBottom.identifier = "Music player bottom"

        collapseMusicPlayerConstraint = NSLayoutConstraint(item: musicPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1)
        collapseMusicPlayerConstraint.identifier = "Collapse Music Player Height"

         smallMusicPlayerConstraint = NSLayoutConstraint(item: musicPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80)
        smallMusicPlayerConstraint.identifier = "Small Music Player Height"

        let navHeight = centralNavigationController.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height

        let totalHeight: CGFloat = UIScreen.mainScreen().bounds.height

        let largeHeight: CGFloat = totalHeight - navHeight - 2*menuBarHeight

         largeMusicPlayerConstraint = NSLayoutConstraint(item: musicPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: largeHeight)
        largeMusicPlayerConstraint.identifier = "Large Music Player Height"
         startMusicPlayerConstraint = NSLayoutConstraint(item: musicPlayerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        startMusicPlayerConstraint.identifier = "Start Music Player Height"

        collapseMusicPlayerConstraint.active = true

        topMenuBar.updateConstraints()
        musicPlayerView.updateConstraints()
        bottomMenuBar.updateConstraints()
    }



    
    required init?(coder aDecoder: NSCoder) {
        fatalError("PlaylistControlView does not support NSCoding")
    }



}