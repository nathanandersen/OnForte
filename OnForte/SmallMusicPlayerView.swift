//
//  SmallMusicPlayerView.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/25/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

/**
 This wrapper for the SmallMusicPlayerView allows us to
 use the XIB file to define the SmallMusicPlayerView, then
 import it into the storyboard.
*/
class SmallMusicPlayerController: UIView {
    private var smallMusicPlayer: SmallMusicPlayerView!
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
        self.addSubview(smallMusicPlayer)

        smallMusicPlayer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Leading, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Top, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Bottom, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: smallMusicPlayer, attribute: .Trailing, multiplier: 1, constant: 0).active = true
        smallMusicPlayer.updateConstraints()
    }
}


class SmallMusicPlayerView: UIView {

    @IBOutlet var songImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var platformImageView: UIImageView!

    internal func displaySongInformation() {
        if let song = PlaylistHandler.nowPlaying {
            ArtworkHandler.lookupArtworkAsync(song.artworkURL, completionHandler: {(image: UIImage) in
                self.songImageView.image = image
                self.setNeedsLayout()
            })
            titleLabel.text = song.title
            descriptionLabel.text = song.description
            platformImageView.image = UIImage(named: (song.service?.asLowerCaseString())!)
        }
    }
}