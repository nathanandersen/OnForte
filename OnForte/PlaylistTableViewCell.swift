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
    @IBOutlet var platformImageView: UIImageView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var votingSwitch: UISwitch!

    @IBOutlet var favoritesStar: UIImageView!
    // want: a favorites star

    internal func loadItem(songId: String, song: MeteorSong) {
        self.songId = songId

        titleLabel.text = song.title
        descriptionLabel.text = song.annotation
        let service = Service(platform: song.platform)
        platformImageView.image = service.getImage()
        scoreLabel.text = String(song.score)

        if PlaylistHandler.getVotingStatus(songId) == .Upvote {
            votingSwitch.on = true
        }
        votingSwitch.tintColor = Service(platform: song.platform).tintColor()

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
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        (sender.on) ? PlaylistHandler.upvote(songId) : PlaylistHandler.downvote(songId)
    }
    
}