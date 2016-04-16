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

    var playButton: UIButton!
// ^^^^^

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
        renderPlatformView()
        renderTitleLabel()
        renderDescriptionLabel()
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
            self.platformView.image = UIImage(named: String(nowPlaying!.service).lowercaseString)
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
    }

    func renderPlatformView() {
        platformView = UIImageView()
        playerView.addSubview(platformView)
        platformView.translatesAutoresizingMaskIntoConstraints = false
    }

    func renderTitleLabel() {
        titleLabel = Style.defaultLabel()
        playerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func renderDescriptionLabel() {
        descriptionLabel = Style.defaultLabel()
        playerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func renderPlayButton() {
        playButton = UIButton()
        playButton.addTarget(self, action: #selector(MusicPlayerView.playButtonDidPress), forControlEvents: .TouchUpInside)
    }

    func renderMusicPlayer() {
        musicPlayer = IntegratedMusicPlayer()
        musicPlayer.control = self
    }

    func playButtonDidPress() {
        musicPlayer.togglePlayingStatus()
    }

    func setPlayButtonStatus(status: Bool) {
        print("did change")
        print(status)
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
        startButton?.updateConstraints()
        self.startButton?.removeFromSuperview()
        self.addSubview(playerView)
        expandedViewConstraints.forEach( {$0.active = true} )
        playerView.updateConstraints()
        displayType = .Large
    }

    func showSmall() {
        startConstraints.forEach( {$0.active = false} )
        expandedViewConstraints.forEach( {$0.active = false} )
        startButton?.updateConstraints()
        self.startButton?.removeFromSuperview()
        self.addSubview(playerView)
        smallViewConstraints.forEach( {$0.active = true} )
        playerView.updateConstraints()
        displayType = .Small
    }

    func collapse() {
        self.subviews.forEach({$0.removeFromSuperview()})
        displayType = .None
    }

    func createStartConstraints() {
        startConstraints.appendContentsOf([
            NSLayoutConstraint(item: startButton!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: startButton!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        ])
    }

    func createSmallConstraints() {
        smallViewConstraints.appendContentsOf([
            NSLayoutConstraint(item: playerView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playerView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        ])
    }

    func createLargeConstraints() {
        expandedViewConstraints.appendContentsOf([
            NSLayoutConstraint(item: playerView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playerView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playerView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playerView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)

        ])
    }




    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding is not implemented for MusicPlayerView")
    }

}