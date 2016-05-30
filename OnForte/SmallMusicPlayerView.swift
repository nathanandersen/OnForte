//
//  SmallMusicPlayerView.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/25/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

/**
 This wrapper for the SmallMusicPlayerView allows us to
 use the XIB file to define the SmallMusicPlayerView, then
 import it into the storyboard.
*/
let updateSmallMusicPlayerKey = "updateSmallMusicPlayer"

class SmallMusicPlayerController: UIView {
    private var smallMusicPlayer: SmallMusicPlayerView!

    /**
     Exposes the delegated small music player's update method.
    */
    internal func updateMusicPlayerDisplay() {
        smallMusicPlayer.displaySongInformation()
    }

    internal func setIsPlaying(result: Bool) {
        smallMusicPlayer.setIsPlaying(result)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        smallMusicPlayer = NSBundle.mainBundle().loadNibNamed("SmallMusicPlayerView", owner: self, options: nil).first as! SmallMusicPlayerView
        smallMusicPlayer.initializePlayButtonFn()
        self.addSubview(smallMusicPlayer)

        // constrain the music player to this view
        smallMusicPlayer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Leading, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        smallMusicPlayer.updateConstraints()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SmallMusicPlayerController.updateMusicPlayerDisplay), name: updateSmallMusicPlayerKey, object: nil)
    }
}


class SmallMusicPlayerView: UIView {

    @IBOutlet var songImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var platformImageView: UIImageView!
    @IBOutlet var fastForwardButton: FastForwardButton!
    @IBOutlet var playButton: BlurredPlayButton!

    internal func setIsPlaying(result: Bool) {
        playButton.setIsPlaying(result)
    }
    @IBAction func fastForwardDidPress(sender: AnyObject) {
        PlaylistHandler.fastForward() { (result) in
            self.playButton.setIsPlaying(result)
        }
    }

    internal func initializePlayButtonFn() {
        playButton.toggleFn = {
            PlaylistHandler.togglePlayingStatus({ (result) in
                self.playButton.setIsPlaying(result)
            })
        }
    }

    internal func displaySongInformation() {
        if let song = PlaylistHandler.nowPlaying {
            ArtworkHandler.lookupArtworkAsync(NSURL(string: song.artworkURL!), completionHandler: {(image: UIImage) in
                self.songImageView.image = image
                self.setNeedsLayout()
            })
            titleLabel.text = song.title
            descriptionLabel.text = song.annotation
            platformImageView.image = MusicPlatform(str: song.musicPlatform!).getImage()
        }
    }
}