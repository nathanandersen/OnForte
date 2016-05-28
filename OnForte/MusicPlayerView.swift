//
//  MusicPlayerView.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/15/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import UIKit
import RSPlayPauseButton
import SwiftDDP

/**
 An enum to describe the size of the MusicPlayer display
 */
enum MusicPlayerDisplayType {
    case None
    case Start
    case Small
    case Large
}

/**
 Returns if an optional string is a valid string with length > 0
 */
func isValidString(str: String?) -> Bool {
    return str != nil && str! != ""
}

/**
 MusicPlayerView displays the variable states of the Music Player:
 collapsed, start, small, and large
 */
class MusicPlayerView: UIView {

    var playerView: UIView!
    var songArtView: UIImageView!
    var platformView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var startButton: UIButton?
    var playButton: BlurredPlayButton!
    var forwardButton: FastForwardButton!

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
        if PlaylistHandler.isHost {
            renderPlayButton()
            renderForwardButton()
            renderStartButton()
        }
        if PlaylistHandler.isHost {
            createStartConstraints()
        }
        createPlayerViewConstraints()
        self.translatesAutoresizingMaskIntoConstraints = false

    }

    /**
    Render the player view
    */
    private func renderPlayerView() {
        playerView = UIView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
    }

    /** 
    Display the now playing song
    */
    internal func displaySong(completionHandler: Bool -> Void) {
        if let nowPlaying = PlaylistHandler.nowPlaying {
            ArtworkHandler.lookupArtworkAsync(nowPlaying.artworkURL, completionHandler: { (image: UIImage) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.songArtView.image = image
                    self.setNeedsLayout()
                })
            })
            //            dispatch_async(dispatch_get_main_queue(), {
            self.titleLabel.text = (isValidString(nowPlaying.title)) ? nowPlaying.title! : "<no title>"
            self.descriptionLabel.text = (isValidString(nowPlaying.description)) ? nowPlaying.description! : "<no description>"
            let platformString = (nowPlaying.service?.asLowerCaseString())!
            self.platformView.image = UIImage(named: platformString)
            //            } )
            completionHandler(true)
        } else {
            completionHandler(false)

        }
    }

    /**
    Render the start button
    */
    private func renderStartButton() {
        startButton = Style.defaultButton("START MUSIC")
        startButton?.backgroundColor = Style.secondaryColor
        startButton?.setTitleColor(Style.whiteColor, forState: .Normal)
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startButton?.addTarget(self, action: #selector(MusicPlayerView.startButtonPress), forControlEvents: .TouchUpInside)
    }

    /**
    Handle the press of the start button, by starting to play music
    */
    internal func startButtonPress() {
        playButton.press()
    }

    /**
    Render the song art view
    */
    private func renderSongArtView() {
        songArtView = UIImageView()
        songArtView.contentMode = UIViewContentMode.ScaleAspectFit
        playerView.addSubview(songArtView)
        songArtView.translatesAutoresizingMaskIntoConstraints = false
        createSongArtConstraints()
    }

    /**
    Create the constraints for the song art view
    */
    private func createSongArtConstraints() {
        let songArtLeading = NSLayoutConstraint(item: songArtView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        songArtLeading.identifier = "Song Art Leading"
        let songArtSmallHeight =  NSLayoutConstraint(item: songArtView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
//        let songArtSmallHeight =  NSLayoutConstraint(item: songArtView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: -10)
        songArtSmallHeight.identifier = "Song art small height"
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
            largeSongArtCenterX,songArtAspect])
    }

    /**
     Render the platform view
    */
    private func renderPlatformView() {
        platformView = UIImageView()
        playerView.addSubview(platformView)
        platformView.translatesAutoresizingMaskIntoConstraints = false
        createPlatformConstraints()
    }

    /**
    Create the platform view constraints
    */
    private func createPlatformConstraints() {
        let platformAspect =
            NSLayoutConstraint(item: platformView, attribute: .Height, relatedBy: .Equal, toItem: platformView, attribute: .Width, multiplier: 1, constant: 0)
        platformAspect.identifier = "Platform Aspect"

        let smallPlatformHeight = NSLayoutConstraint(item: platformView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: -20)
        smallPlatformHeight.identifier = "Small Platform Height"

        let smallPlatformCenterY = NSLayoutConstraint(item: platformView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        smallPlatformCenterY.identifier = "Small Platform Center Y"
        let smallPlatformLeadingTitle = NSLayoutConstraint(item: platformView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: titleLabel, attribute: .Trailing, multiplier: 1, constant: 5)
        smallPlatformLeadingTitle.identifier = "Small Platform Leading Title"
        let smallPlatformLeadingDescription = NSLayoutConstraint(item: platformView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: descriptionLabel, attribute: .Trailing, multiplier: 1, constant: 5)
        smallPlatformLeadingDescription.identifier = "Small Platform Leading Description"

        let largePlatformTop = NSLayoutConstraint(item: platformView, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: descriptionLabel, attribute: .Bottom, multiplier: 1, constant: 5)
        largePlatformTop.identifier = "Large Platform Top"
        let largePlatformCenterX = NSLayoutConstraint(item: platformView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largePlatformCenterX.identifier = "Large Platform Center X"
        let platformSpace = NSLayoutConstraint(item: platformView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        platformSpace.identifier = "Platform space filler"

        smallViewConstraints.appendContentsOf([platformAspect,smallPlatformHeight,smallPlatformCenterY/*,smallPlatformTrailing*/,smallPlatformLeadingTitle,smallPlatformLeadingDescription])
        expandedViewConstraints.appendContentsOf([platformAspect,largePlatformTop,largePlatformCenterX,platformSpace])
        /*            NSLayoutConstraint(item: platformView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1/5, constant: 0)*/
    }

    /**
    Render the title label
    */
    private func renderTitleLabel() {
        titleLabel = Style.defaultLabel()
        titleLabel.textAlignment = .Left
        titleLabel.font = Style.defaultFont(10)
        playerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        createTitleLabelConstraints()
    }

    /**
    Add constraints to the title label
    */
    private func createTitleLabelConstraints() {
        let smallTitleLeading = NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: songArtView, attribute: .Trailing, multiplier: 1, constant: 5)
        smallTitleLeading.identifier = "Small Title Leading"
        let smallTitleTop = NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -2)
        smallTitleTop.identifier = "Small Title Top"
        smallViewConstraints.appendContentsOf([smallTitleLeading,smallTitleTop])
        let largeTitleTop = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: songArtView, attribute: .Bottom, multiplier: 1, constant: 5)
        largeTitleTop.identifier = "large title top"
        let largeTitleCenterX = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largeTitleCenterX.identifier = "large title center x"

        expandedViewConstraints.appendContentsOf([largeTitleTop,largeTitleCenterX])
    }

    /**
    Render the description label
    */
    private func renderDescriptionLabel() {
        descriptionLabel = Style.defaultLabel()
        descriptionLabel.textAlignment = .Left
        descriptionLabel.font = Style.defaultFont(10)
        playerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        createDescriptionLabelConstraints()
    }
    /**
    Add constraints to the description label
    */
    private func createDescriptionLabelConstraints() {
        let smallDescriptionLeading = NSLayoutConstraint(item: descriptionLabel, attribute: .Leading, relatedBy: .Equal, toItem: songArtView, attribute: .Trailing, multiplier: 1, constant: 5)
        smallDescriptionLeading.identifier = "Small Description Leading"
        let smallDescriptionTop = NSLayoutConstraint(item: descriptionLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 2)
        smallDescriptionTop.identifier = "Small Description Top"
        smallViewConstraints.appendContentsOf([smallDescriptionLeading,smallDescriptionTop])
        let largeDescriptionTop = NSLayoutConstraint(item: descriptionLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 5)
        largeDescriptionTop.identifier = "Large Description Top"
        let largeDescriptionCenter = NSLayoutConstraint(item: descriptionLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        largeDescriptionCenter.identifier = "Large Description Center"
        expandedViewConstraints.appendContentsOf([largeDescriptionTop,largeDescriptionCenter])

    }

    /**
     Handle the pressing of the play-pause button
     - returns: the final state of the play button
    */
    func playPauseDidPress() {
        PlaylistHandler.togglePlayingStatus({ (result) in
            self.playButton.setIsPlaying(result)
        })
    }

    /**
    Render the play button
    */
    private func renderPlayButton() {
        playButton = BlurredPlayButton()
        playButton.showsTouchWhenHighlighted = true
        playButton.toggleFn = self.playPauseDidPress
        playButton.translatesAutoresizingMaskIntoConstraints = false
        songArtView.addSubview(playButton)
        addPlayButtonConstraints()
    }
    /**
    Add constraints to the play button
    */
    private func addPlayButtonConstraints() {

        let buttonSmallCenterX = NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: songArtView, attribute: .CenterX, multiplier: 1, constant: 0)
        buttonSmallCenterX.identifier = "button small center x"
        let buttonLargeCenterX = NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: platformView, attribute: .CenterX, multiplier: 1, constant: 0)
        buttonLargeCenterX.identifier = "button large center x"
        let buttonSmallCenterY = NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: songArtView, attribute: .CenterY, multiplier: 1, constant: 0)
        buttonSmallCenterY.identifier = "button small center y"
        let buttonLargeCenterY = NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: platformView, attribute: .CenterY, multiplier: 1, constant: 0)
        buttonLargeCenterY.identifier = "button large center y"

        let buttonSmallWidth = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: songArtView, attribute: .Width, multiplier: 0.60, constant: 0)
        buttonSmallWidth.identifier = "button small width"
        let buttonLargeWidth = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: platformView, attribute: .Width, multiplier: 0.60, constant: 0)
        buttonLargeWidth.identifier = "button large width"



        let playAspect = NSLayoutConstraint(item: playButton, attribute: .Width, relatedBy: .Equal, toItem: playButton, attribute: .Height, multiplier: 1, constant: 0)
        playAspect.identifier = "play Aspect"

        smallViewConstraints.appendContentsOf([buttonSmallWidth,buttonSmallCenterX,buttonSmallCenterY,playAspect])
        expandedViewConstraints.appendContentsOf([buttonLargeWidth,buttonLargeCenterX,buttonLargeCenterY,playAspect])
    }

    /**
    Handle the press of the fast forward button
    */
    internal func fastForward() {
        PlaylistHandler.fastForward() { (result) in
            self.playButton.setIsPlaying(result)
        }
    }

    /**
    Render the fast forward button 
    */
    private func renderForwardButton() {
        forwardButton = FastForwardButton()
        forwardButton.showsTouchWhenHighlighted = true
        playerView.addSubview(forwardButton)
        forwardButton.addTarget(self, action: #selector(MusicPlayerView.fastForward), forControlEvents: .TouchUpInside)
        addConstraintsToForwardButton()
    }

    /**
    Add constraints to the forward button
    */
    private func addConstraintsToForwardButton() {
        forwardButton.translatesAutoresizingMaskIntoConstraints = false

        let leftConstraint = NSLayoutConstraint(item: forwardButton, attribute: .Left, relatedBy: .Equal, toItem: platformView, attribute: .Right, multiplier: 1, constant: 10)
        leftConstraint.identifier = "forward button left constraint"
        let centerYConstraint = NSLayoutConstraint(item: forwardButton, attribute: .CenterY, relatedBy: .Equal, toItem: platformView, attribute: .CenterY, multiplier: 1, constant: 0)
        centerYConstraint.identifier = "forward button center y"
        let aspectConstraint = NSLayoutConstraint(item: forwardButton, attribute: .Height, relatedBy: .Equal, toItem: forwardButton, attribute: .Width, multiplier: 1, constant: 0)
        aspectConstraint.identifier = "forward button aspect"
        let heightConstraint = NSLayoutConstraint(item: forwardButton, attribute: .Height, relatedBy: .Equal, toItem: playButton, attribute: .Height, multiplier: 1, constant: 0)
        heightConstraint.identifier = "forward button height"
        let smallRightConstraint = NSLayoutConstraint(item: forwardButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10)
        smallRightConstraint.identifier = "forward button small right"

        smallViewConstraints.appendContentsOf([leftConstraint,centerYConstraint,aspectConstraint,heightConstraint,smallRightConstraint])
        expandedViewConstraints.appendContentsOf([leftConstraint,centerYConstraint,aspectConstraint,heightConstraint])
    }

    /**
    Show the start button
    */
    internal func showStart() {
        self.constraints.forEach( {$0.active = false} )
        playerView.updateConstraints()
        self.playerView.removeFromSuperview()
        self.addSubview(startButton!)
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startConstraints.forEach( {$0.active = true} )
        displayType = .Start
    }
    /**
    Show the large music display
    */
    internal func showLarge() {
        playButton.removeFromSuperview()
        playButton.constraints.forEach({$0.active = false})
        subviews.forEach({
            $0.constraints.forEach({$0.active = false})
            $0.removeFromSuperview()
        })
        addSubview(playerView)
        platformView.userInteractionEnabled = true
        platformView.addSubview(playButton)
        expandedViewConstraints.forEach({$0.active = true})
        displayType = .Large
        // re-draw artwork image?
        playButton.setNeedsDisplay()
        descriptionLabel.textAlignment = .Center
    }

    /**
    Show the small music display
    */
    internal func showSmall() {
        playButton.removeFromSuperview()
        playButton.constraints.forEach({$0.active = false})
        subviews.forEach({
            $0.constraints.forEach({$0.active = false})
            $0.removeFromSuperview()
        })
        addSubview(playerView)
        songArtView.userInteractionEnabled = true
        songArtView.addSubview(playButton)
        smallViewConstraints.forEach({$0.active = true})
        displayType = .Small
        playButton.setNeedsDisplay()
        descriptionLabel.textAlignment = .Natural
    }

    /**
    Collapse the music display  
    */
    internal func collapse() {
        subviews.forEach({
            $0.constraints.forEach({$0.active = false})
            $0.removeFromSuperview()
        })
        displayType = .None
    }

    /**
    Create the start button constraints
    */
    private func createStartConstraints() {
        let startLeading = NSLayoutConstraint(item: startButton!, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 80)
        startLeading.identifier = "Start Leading"
        let startTrailing = NSLayoutConstraint(item: startButton!, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -80)
        startTrailing.identifier = "Start Trailing"
        let startTop = NSLayoutConstraint(item: startButton!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        startTop.identifier = "Start Top"
        let startBottom = NSLayoutConstraint(item: startButton!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        startBottom.identifier = "Start Bottom"
        startConstraints.appendContentsOf([startLeading,startTrailing,startTop,startBottom])
    }
    /**
    Create the player view constraints  
    */
    private func createPlayerViewConstraints() {
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