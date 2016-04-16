//
//  MusicPlayerView.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/15/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import UIKit
import RSPlayPauseButton
import SwiftDDP


enum MusicPlayerDisplayType {
    case None
    case Start
    case Small
    case Large
}

class MusicPlayerView: UIView {

    var playerView: UIView!
    var songArtView: UIImageView!
    var platformView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!

    var startButton: UIButton?
    var musicPlayer: IntegratedMusicPlayer!

    var playPauseButton: RSPlayPauseButton!

    var forwardButton: UIButton?
    var playlistController: PlaylistController!
    var displayType: MusicPlayerDisplayType

    var expandedViewConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    var smallViewConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    var startConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()

    override init(frame: CGRect) {
        self.displayType = .None
        super.init(frame: frame)
        renderPlayerView()
        renderSongArtView()
        renderTitleLabel()
        renderDescriptionLabel()
        renderPlatformView()
        if isHost {
            renderPlayButton()
            renderMusicPlayer()
            renderForwardButton()
            renderStartButton()
        }
        if isHost {
            createStartConstraints()
        }
        createSmallConstraints()
        createLargeConstraints()
        self.translatesAutoresizingMaskIntoConstraints = false

    }
    func setParentPlaylistController(playlistC: PlaylistController) {
        self.playlistController = playlistC
        musicPlayer.playlistController = playlistC
    }

    func renderPlayerView() {
        playerView = UIView()
    }

    func displaySong() {
        dispatch_async(dispatch_get_main_queue(), {
            artworkHandler.lookupForImageView(nowPlaying!.artworkURL, imageView: self.songArtView)
            self.titleLabel.text = nowPlaying!.title
            self.descriptionLabel.text = nowPlaying!.description
            let platformString = (nowPlaying!.service?.asLowerCaseString())!
            print(platformString)
            self.platformView.image = UIImage(named: platformString)
        } )
    }

    func renderStartButton() {
        startButton = Style.defaultButton("START MUSIC")
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startButton?.addTarget(self, action: #selector(MusicPlayerView.startButtonPress), forControlEvents: .TouchUpInside)
    }

    func startButtonPress() {
        musicPlayer.playNextSong()
    }

    func renderSongArtView() {
        songArtView = UIImageView()
        playerView.addSubview(songArtView)
        songArtView.translatesAutoresizingMaskIntoConstraints = false
        createSongArtConstraints()
    }

    func createSongArtConstraints() {
        let songArtLeading = NSLayoutConstraint(item: songArtView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        let songArtSmallHeight =  NSLayoutConstraint(item: songArtView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: -10)
        songArtLeading.identifier = "Song Art Leading"
        let songArtAspect =  NSLayoutConstraint(item: songArtView, attribute: .Height, relatedBy: .Equal, toItem: songArtView, attribute: .Width, multiplier: 1, constant: 0)
        songArtAspect.identifier = "Song Art Aspect"
        let smallSongArtCenterY = NSLayoutConstraint(item: songArtView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        smallSongArtCenterY.identifier = "Small Song Art Center Y"
        let largeSongArtCenterX = NSLayoutConstraint(item: songArtView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largeSongArtCenterX.identifier = "Large Song Art Center X"
        let largeSongArtTrailing = NSLayoutConstraint(item: songArtView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        largeSongArtTrailing.identifier = "Large Song Art Trailing"
        let largeSongArtTop = NSLayoutConstraint(item: songArtView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        largeSongArtTop.identifier = "Large Song Art Top"

        smallViewConstraints.appendContentsOf([songArtLeading,songArtSmallHeight,smallSongArtCenterY,songArtAspect])
        expandedViewConstraints.appendContentsOf([songArtLeading,largeSongArtTrailing,largeSongArtTop,
            largeSongArtCenterX,songArtAspect
        ])
    }

    func renderPlatformView() {
        platformView = UIImageView()
        playerView.addSubview(platformView)
        platformView.translatesAutoresizingMaskIntoConstraints = false
        createPlatformConstraints()
    }

    func createPlatformConstraints() {
        let platformAspect =
            NSLayoutConstraint(item: platformView, attribute: .Height, relatedBy: .Equal, toItem: platformView, attribute: .Width, multiplier: 1, constant: 0)
        platformAspect.identifier = "Platform Aspect"
        let smallPlatformHeight = NSLayoutConstraint(item: platformView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: -40)
        smallPlatformHeight.identifier = "Small Platform Height"

        let smallPlatformCenterY = NSLayoutConstraint(item: platformView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        smallPlatformCenterY.identifier = "Small Platform Center Y"
        let smallPlatformTrailing = NSLayoutConstraint(item: platformView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        smallPlatformTrailing.identifier = "Small Platform Trailing"
        let smallPlatformLeadingTitle = NSLayoutConstraint(item: platformView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: titleLabel, attribute: .Trailing, multiplier: 1, constant: 5)
        smallPlatformLeadingTitle.identifier = "Small Platform Leading Title"
        let smallPlatformLeadingDescription = NSLayoutConstraint(item: platformView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: descriptionLabel, attribute: .Trailing, multiplier: 1, constant: 5)
        smallPlatformLeadingDescription.identifier = "Small Platform Leading Description"

        let largePlatformTop = NSLayoutConstraint(item: platformView, attribute: .Top, relatedBy: .Equal, toItem: descriptionLabel, attribute: .Bottom, multiplier: 1, constant: 5)
        largePlatformTop.identifier = "Large Platform Top"
        let largePlatformCenterX = NSLayoutConstraint(item: platformView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largePlatformCenterX.identifier = "Large Platform Center X"

        smallViewConstraints.appendContentsOf([platformAspect,smallPlatformHeight,smallPlatformCenterY,smallPlatformTrailing,smallPlatformLeadingTitle,smallPlatformLeadingDescription])
        expandedViewConstraints.appendContentsOf([platformAspect,largePlatformTop,largePlatformCenterX
            ])
        /*            NSLayoutConstraint(item: platformView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1/5, constant: 0)*/
    }

    func renderTitleLabel() {
        titleLabel = Style.defaultLabel()
        titleLabel.textAlignment = .Left
        titleLabel.font = Style.defaultFont(10)
        playerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        createTitleLabelConstraints()
    }

    func createTitleLabelConstraints() {
        let smallTitleLeading = NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: songArtView, attribute: .Trailing, multiplier: 1, constant: 5)
        smallTitleLeading.identifier = "Small Title Leading"
        let smallTitleTop = NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -2)
        smallTitleTop.identifier = "Small Title Top"
        smallViewConstraints.appendContentsOf([smallTitleLeading,smallTitleTop])
        expandedViewConstraints.appendContentsOf([
            NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: songArtView, attribute: .Bottom, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        ])
    }

    func renderDescriptionLabel() {
        descriptionLabel = Style.defaultLabel()
        descriptionLabel.textAlignment = .Left
        descriptionLabel.font = Style.defaultFont(10)
        playerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        createDescriptionLabelConstraints()
    }

    func createDescriptionLabelConstraints() {
        let smallDescriptionLeading = NSLayoutConstraint(item: descriptionLabel, attribute: .Leading, relatedBy: .Equal, toItem: songArtView, attribute: .Trailing, multiplier: 1, constant: 5)
        smallDescriptionLeading.identifier = "Small Description Leading"
        let smallDescriptionTop = NSLayoutConstraint(item: descriptionLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 2)
        smallDescriptionTop.identifier = "Small Description Top"
        smallViewConstraints.appendContentsOf([smallDescriptionLeading,smallDescriptionTop])
        let largeDescriptionTop = NSLayoutConstraint(item: descriptionLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 5)
        largeDescriptionTop.identifier = "Large Description Top"
        let largeDescriptionCenter = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largeDescriptionCenter.identifier = "Large Description Center"
        expandedViewConstraints.appendContentsOf([largeDescriptionTop,largeDescriptionCenter])

    }

    func renderPlayButton() {
        playPauseButton = RSPlayPauseButton()
        playPauseButton.addTarget(self, action: #selector(MusicPlayerView.playButtonDidPress), forControlEvents: .TouchUpInside)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        songArtView.addSubview(playPauseButton)
        // ^ change this depending on the situation
        addPlayButtonConstraints()
    }

    func addPlayButtonConstraints() {
        let playPauseCenterX = NSLayoutConstraint(item: playPauseButton, attribute: .CenterX, relatedBy: .Equal, toItem: playPauseButton.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        playPauseCenterX.identifier = "Play Pause Center X"
        let playPauseCenterY = NSLayoutConstraint(item: playPauseButton, attribute: .CenterY, relatedBy: .Equal, toItem: playPauseButton.superview, attribute: .CenterY, multiplier: 1, constant: 0)
        playPauseCenterY.identifier = "Play Pause Center Y"
        let playPauseAspect = NSLayoutConstraint(item: playPauseButton, attribute: .Width, relatedBy: .Equal, toItem: playPauseButton, attribute: .Height, multiplier: 1, constant: 0)
        playPauseAspect.identifier = "Play Pause Aspect"
        let playPauseWidth = NSLayoutConstraint(item: playPauseButton, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: playPauseButton.superview, attribute: .Width, multiplier: 1/2, constant: 0)
        playPauseWidth.identifier = "Play Pause Width"
        smallViewConstraints.appendContentsOf([playPauseCenterX,playPauseCenterY,playPauseAspect,playPauseWidth])
        expandedViewConstraints.appendContentsOf([playPauseCenterX,playPauseCenterY,playPauseAspect,playPauseWidth])
    }

    func renderMusicPlayer() {
        musicPlayer = IntegratedMusicPlayer()
        musicPlayer.control = self
    }

    func playButtonDidPress() {
        print("did press")
//        musicPlayer.togglePlayingStatus()
    }

    func setPlayButtonStatus(status: Bool) {
        playPauseButton.setPaused(status, animated: true)
//        print("did change")
//        print(status)
    }

    func renderForwardButton() {

    }

    func showStart() {
        smallViewConstraints.forEach( {$0.active = false} )
        expandedViewConstraints.forEach( {$0.active = false} )
        playerView.updateConstraints()
        self.playerView.removeFromSuperview()
        self.addSubview(startButton!)
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startConstraints.forEach( {$0.active = true} )
        startButton!.updateConstraints()
        displayType = .Start
    }

    func showLarge() {
        smallViewConstraints.forEach( {$0.active = false} )
        startConstraints.forEach( {$0.active = false} )

        self.playPauseButton.removeFromSuperview()

        startButton?.updateConstraints()
        self.startButton?.removeFromSuperview()
        self.addSubview(playerView)

        platformView.userInteractionEnabled = true
        platformView.addSubview(playPauseButton)

        expandedViewConstraints.forEach( {$0.active = true} )
        playerView.updateConstraints()
        displayType = .Large

        // re-draw image?
    }

    func showSmall() {
        startConstraints.forEach( {$0.active = false} )
        expandedViewConstraints.forEach( {$0.active = false} )

        self.playPauseButton.removeFromSuperview()

        startButton?.updateConstraints()
        self.startButton?.removeFromSuperview()
        self.addSubview(playerView)

        songArtView.userInteractionEnabled = true
        songArtView.addSubview(playPauseButton)

        smallViewConstraints.forEach( {$0.active = true} )
        playerView.updateConstraints()
        displayType = .Small
    }

    func collapse() {
        self.subviews.forEach({$0.removeFromSuperview()})
        displayType = .None
    }

    func createStartConstraints() {
        let startLeading = NSLayoutConstraint(item: startButton!, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        startLeading.identifier = "Start Leading"
        let startTrailing = NSLayoutConstraint(item: startButton!, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        startTrailing.identifier = "Start Trailing"
        let startTop = NSLayoutConstraint(item: startButton!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        startTop.identifier = "Start Top"
        let startBottom = NSLayoutConstraint(item: startButton!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        startBottom.identifier = "Start Bottom"
        startConstraints.appendContentsOf([startLeading,startTrailing,startTop,startBottom])
    }

    func createSmallConstraints() {
        let smallLeading = NSLayoutConstraint(item: playerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        smallLeading.identifier = "Small Leading"
        let smallTrailing = NSLayoutConstraint(item: playerView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        smallTrailing.identifier = "Small Trailing"
        let smallTop = NSLayoutConstraint(item: playerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        smallTop.identifier = "Small Top"
        let smallBottom = NSLayoutConstraint(item: playerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        smallBottom.identifier = "Small Bottom"
        smallViewConstraints.appendContentsOf([smallLeading,smallTrailing,smallTop,smallBottom])
    }

    func createLargeConstraints() {
        let largeLeading = NSLayoutConstraint(item: playerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        largeLeading.identifier = "Large Leading"
        let largeTrailing = NSLayoutConstraint(item: playerView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        largeTrailing.identifier = "Large Trailing"
        let largeTop = NSLayoutConstraint(item: playerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        largeTop.identifier = "Large Top"
        let largeBottom = NSLayoutConstraint(item: playerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        largeBottom.identifier = "Large Bottom"
        expandedViewConstraints.appendContentsOf([largeLeading,largeTrailing,largeTop,largeBottom])
    }




    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding is not implemented for MusicPlayerView")
    }

}