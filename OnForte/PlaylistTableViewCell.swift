//
//  PlaylistTableViewCell.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

class PlaylistTableViewCell: UITableViewCell {

    private var songId: String!
    @IBOutlet var songArtworkView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    // rename this
    @IBOutlet var platformImageView: UIImageView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var votingSwitch: UISwitch!

    @IBOutlet var favoritesStar: UIImageView!
    // want: a favorites star

    internal func loadItem(song: QueuedSong) {
        self.songId = song.id
        titleLabel.text = song.title
        descriptionLabel.text = song.annotation
        let musicPlatform = MusicPlatform(str: song.musicPlatform!)
        platformImageView.image = musicPlatform.getImage()
        scoreLabel.text = String(song.score!)

        votingSwitch.on = PlaylistHandler.hasBeenUpvoted(songId)

        votingSwitch.tintColor = musicPlatform.tintColor()
        if let url = song.artworkURL {
            ArtworkHandler.lookupArtworkAsync(NSURL(string: url), completionHandler: { (image: UIImage) in
                self.songArtworkView.image = image
                self.setNeedsLayout()
            })
        } else {
            songArtworkView.image = musicPlatform.getImage()
        }

        // still have to do favorites // suggestions
    }

/*    internal func loadItem(songId: String, song: MeteorSong) {
        self.songId = songId

        titleLabel.text = song.title
        descriptionLabel.text = song.annotation
        let service = Service(platform: song.platform)
        platformImageView.image = service.getImage()
        scoreLabel.text = String(song.score)

        votingSwitch.on = PlaylistHandler.hasBeenUpvoted(songId)

        votingSwitch.tintColor = service.tintColor()

        if let url = song.artworkURL {
            ArtworkHandler.lookupArtworkAsync(NSURL(string: url)!, completionHandler: { (image: UIImage) in
                self.songArtworkView.image = image
                self.setNeedsLayout()
            })
        } else {
            songArtworkView.image = service.getImage()
        }

        let songValue = InternalSong(songDoc: song)
        if SongHandler.isSuggestion(songValue) || SongHandler.isFavorite(songValue) {
            favoritesStar.hidden = false
        } else {
            favoritesStar.hidden = true
        }
    }*/

    @IBAction func switchValueChanged(sender: UISwitch) {
        (sender.on) ? PlaylistHandler.upvote(songId) : PlaylistHandler.downvote(songId)
    }
    
}