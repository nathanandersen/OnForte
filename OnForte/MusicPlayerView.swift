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

class MusicPlayerView: UIView {

    var songArtView: UIImageView!
    var platformView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!

    var startButton: UIButton?
    var musicPlayer: MusicPlayer!
    var forwardButton: UIButton?

    var expandedViewConstraints: [NSLayoutConstraint]!
    var smallViewConstraints: [NSLayoutConstraint]!
//    var collapsedConstraints: [NSLayoutConstraint]!
    var startConstraints: [NSLayoutConstraint]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        renderSongArtView()
        renderPlatformView()
        renderTitleLabel()
        renderDescriptionLabel()
        if isHost {
            renderMusicPlayer()
            renderForwardButton()
            renderStartButton()
        }
        if isHost {
            createStartConstraints()
        }
//        createCollapsedConstraints()
        createSmallConstraints()
        createLargeConstraints()
//        collapsedConstraints.forEach({$0.active = true})
        self.updateConstraints()
    }

    func displaySong() {
        dispatch_async(dispatch_get_main_queue(), {
            artworkHandler.lookupForImageView(nowPlaying!.artworkURL, imageView: self.songArtView)
            self.titleLabel.text = nowPlaying!.title
            self.descriptionLabel.text = nowPlaying!.description
            self.platformView.image = UIImage(named: String(nowPlaying!.service).lowercaseString)
        } )
    }

    func renderStartButton() {
        startButton = Style.defaultButton("START MUSIC")
        startButton?.translatesAutoresizingMaskIntoConstraints = false
        startButton?.addTarget(self, action: #selector(MusicPlayerView.startButtonPress), forControlEvents: .TouchUpInside)
        self.addSubview(startButton!)
    }

    func startButtonPress() {
        musicPlayer.playNextSong()
    }

    func renderSongArtView() {
        songArtView = UIImageView()
        self.addSubview(songArtView)
    }

    func renderPlatformView() {
        platformView = UIImageView()
        self.addSubview(platformView)
    }

    func renderTitleLabel() {
        titleLabel = Style.defaultLabel()
        self.addSubview(titleLabel)
    }

    func renderDescriptionLabel() {
        descriptionLabel = Style.defaultLabel()
        self.addSubview(descriptionLabel)
    }

    func renderMusicPlayer() {
        musicPlayer = MusicPlayer()
        musicPlayer.parentView = self
        self.songArtView.addSubview(musicPlayer)
        self.musicPlayer.addTarget(self, action: #selector(MusicPlayerView.musicPlayerButtonDidPress), forControlEvents: .TouchUpInside)
    }

    func musicPlayerButtonDidPress() {
        musicPlayer.didPress()
    }

    func renderForwardButton() {

    }

    func showStart() {
        smallViewConstraints.forEach( {$0.active = false} )
        expandedViewConstraints.forEach( {$0.active = false} )
//        collapsedConstraints.forEach( {$0.active = false} )
        startConstraints.forEach( {$0.active = true} )
        self.updateConstraints()
    }

    func showLarge() {
//        collapsedConstraints.forEach( {$0.active = false} )
        startConstraints.forEach( {$0.active = false} )
        smallViewConstraints.forEach( {$0.active = false} )
        expandedViewConstraints.forEach( {$0.active = true} )
        self.updateConstraints()
    }

    func showSmall() {
//        collapsedConstraints.forEach( {$0.active = false} )
        startConstraints.forEach( {$0.active = false} )
        expandedViewConstraints.forEach( {$0.active = false} )
        smallViewConstraints.forEach( {$0.active = true} )
        self.updateConstraints()
    }

    func collapse() {
//        smallViewConstraints.forEach( {$0.active = false} )
        startConstraints.forEach( {$0.active = false} )
//        expandedViewConstraints.forEach( {$0.active = false} )
//        collapsedConstraints.forEach( {$0.active = true} )

        // remove all subviews?

        self.updateConstraints()
    }

    func createStartConstraints() {
        startConstraints = [
            NSLayoutConstraint(item: startButton!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        ]
    }

/*    func createCollapsedConstraints() {
        collapsedConstraints = [

        ]
    }*/

    func createSmallConstraints() {

    }

    func createLargeConstraints() {

    }




    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding is not implemented for MusicPlayerView")
    }

}