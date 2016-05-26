//
//  SmallMusicPlayerView.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/25/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

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