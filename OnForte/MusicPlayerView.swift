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

import SVGPlayButton


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

    var playButton: SVGPlayButton!

//    var playPauseButton: RSPlayPauseButton!

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
        createPlayerViewConstraints()
        self.translatesAutoresizingMaskIntoConstraints = false

    }
    func setParentPlaylistController(playlistC: PlaylistController) {
        self.playlistController = playlistC
        musicPlayer.playlistController = playlistC
    }

    func renderPlayerView() {
        playerView = UIView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
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
        let platformSpace = NSLayoutConstraint(item: platformView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        platformSpace.identifier = "Platform space filler"

        smallViewConstraints.appendContentsOf([platformAspect,smallPlatformHeight,smallPlatformCenterY,smallPlatformTrailing,smallPlatformLeadingTitle,smallPlatformLeadingDescription])
        expandedViewConstraints.appendContentsOf([platformAspect,largePlatformTop,largePlatformCenterX,platformSpace])
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
        let largeTitleTop = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: songArtView, attribute: .Bottom, multiplier: 1, constant: 5)
        largeTitleTop.identifier = "large title top"
        let largeTitleCenterX = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largeTitleCenterX.identifier = "large title center x"

        expandedViewConstraints.appendContentsOf([largeTitleTop,largeTitleCenterX])
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
        playButton = SVGPlayButton()
        playButton.willPlay = {self.playButtonDidPress() }
        playButton.willPause = {self.playButtonDidPress() }
        playButton.translatesAutoresizingMaskIntoConstraints = false
        songArtView.addSubview(playButton)


//        playPauseButton = RSPlayPauseButton()
//        playPauseButton.addTarget(self, action: #selector(MusicPlayerView.playButtonDidPress), forControlEvents: .TouchUpInside)
//        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
//        songArtView.addSubview(playPauseButton)
//        addPlayButtonConstraints()
    }

    func addPlayButtonConstraints() {
        let playAspect = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: playButton, attribute: .Height, multiplier: 1, constant: 0)
        playAspect.identifier = "Play Pause Aspect"


        let smallPlayCenterX = NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: playButton.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        smallPlayCenterX.identifier = "Play Pause Center X"
        let largePlayCenterX = NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: playButton.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        largePlayCenterX.identifier = "Play Pause Center X"
        let smallPlayCenterY = NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: songArtView, attribute: .CenterY, multiplier: 1, constant: 0)
        smallPlayCenterY.identifier = "Play Pause Center Y"
        let largePlayCenterY = NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: platformView, attribute: .CenterY, multiplier: 1, constant: 0)
        largePlayCenterY.identifier = "Play Pause Center Y"

        let smallPlayWidth = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: songArtView, attribute: .Width, multiplier: 1/2, constant: 0)
        smallPlayWidth.identifier = "Play Pause Width"
        let largePlayWidth = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: platformView, attribute: .Width, multiplier: 1/2, constant: 0)
        largePlayWidth.identifier = "Play Pause Width"
        smallViewConstraints.appendContentsOf([smallPlayCenterX,smallPlayCenterY,playAspect,smallPlayWidth])
        expandedViewConstraints.appendContentsOf([largePlayCenterX,largePlayCenterY,playAspect,largePlayWidth])
/*        let playPauseAspect = NSLayoutConstraint(item: playPauseButton, attribute: .Width, relatedBy: .Equal, toItem: playPauseButton, attribute: .Height, multiplier: 1, constant: 0)
        playPauseAspect.identifier = "Play Pause Aspect"


        let smallPlayPauseCenterX = NSLayoutConstraint(item: playPauseButton, attribute: .CenterX, relatedBy: .Equal, toItem: playPauseButton.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        smallPlayPauseCenterX.identifier = "Play Pause Center X"
        let largePlayPauseCenterX = NSLayoutConstraint(item: playPauseButton, attribute: .CenterX, relatedBy: .Equal, toItem: playPauseButton.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        largePlayPauseCenterX.identifier = "Play Pause Center X"
        let smallPlayPauseCenterY = NSLayoutConstraint(item: playPauseButton, attribute: .CenterY, relatedBy: .Equal, toItem: songArtView, attribute: .CenterY, multiplier: 1, constant: 0)
        smallPlayPauseCenterY.identifier = "Play Pause Center Y"
        let largePlayPauseCenterY = NSLayoutConstraint(item: playPauseButton, attribute: .CenterY, relatedBy: .Equal, toItem: platformView, attribute: .CenterY, multiplier: 1, constant: 0)
        largePlayPauseCenterY.identifier = "Play Pause Center Y"

        let smallPlayPauseWidth = NSLayoutConstraint(item: playPauseButton, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: songArtView, attribute: .Width, multiplier: 1/2, constant: 0)
        smallPlayPauseWidth.identifier = "Play Pause Width"
        let largePlayPauseWidth = NSLayoutConstraint(item: playPauseButton, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: platformView, attribute: .Width, multiplier: 1/2, constant: 0)
        largePlayPauseWidth.identifier = "Play Pause Width"
        smallViewConstraints.appendContentsOf([smallPlayPauseCenterX,smallPlayPauseCenterY,playPauseAspect,smallPlayPauseWidth])
        expandedViewConstraints.appendContentsOf([largePlayPauseCenterX,largePlayPauseCenterY,playPauseAspect,largePlayPauseWidth])*/
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
        print("bow wow wow")
        // set the status?!?!
//        playButton.isPlaying = status

        //        playPauseButton.setPaused(status, animated: true)
    }

    func renderForwardButton() {

    }

    func showStart() {
        self.constraints.forEach( {$0.active = false} )

        playerView.updateConstraints()
        self.playerView.removeFromSuperview()
        self.addSubview(startButton!)
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startConstraints.forEach( {$0.active = true} )
        subviews.forEach({$0.updateConstraints()})
        displayType = .Start
    }

    func showLarge() {
        print("why am i here?")
        playButton.removeFromSuperview()
        playButton.constraints.forEach({$0.active = false})

/*        playPauseButton.removeFromSuperview()
        playPauseButton.constraints.forEach({$0.active = false})*/

        subviews.forEach({
            $0.constraints.forEach({$0.active = false})
            $0.removeFromSuperview()
        })

        addSubview(playerView)
        platformView.userInteractionEnabled = true
//        platformView.addSubview(playPauseButton)
        platformView.addSubview(playButton)

        expandedViewConstraints.forEach({$0.active = true})
        subviews.forEach({$0.updateConstraints()})
        displayType = .Large
        // re-draw image?
    }

    func showSmall() {

        playButton.removeFromSuperview()
        playButton.constraints.forEach({$0.active = false})
/*        playPauseButton.removeFromSuperview()
        playPauseButton.constraints.forEach({$0.active = false})*/

        subviews.forEach({
            $0.constraints.forEach({$0.active = false})
            $0.removeFromSuperview()
        })

        addSubview(playerView)
        songArtView.userInteractionEnabled = true
//        songArtView.addSubview(playPauseButton)
        songArtView.addSubview(playButton)

        smallViewConstraints.forEach({$0.active = true})
        subviews.forEach({$0.updateConstraints()})
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

    func createPlayerViewConstraints() {
        let smallLeading = NSLayoutConstraint(item: playerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        smallLeading.identifier = "PView Leading"
        let smallTrailing = NSLayoutConstraint(item: playerView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        smallTrailing.identifier = "PView Trailing"
        let smallTop = NSLayoutConstraint(item: playerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        smallTop.identifier = "PView Top"
        let smallBottom = NSLayoutConstraint(item: playerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        smallBottom.identifier = "PV Bottom"
        let constraints = [smallLeading,smallTrailing,smallTop,smallBottom]
        smallViewConstraints.appendContentsOf(constraints)
        expandedViewConstraints.appendContentsOf(constraints)
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding is not implemented for MusicPlayerView")
    }

}