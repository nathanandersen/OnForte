//
//  PlaylistTableViewCell.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
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

    //    override func awakeFromNib() {
//        super.awakeFromNib()
//    }

    internal func loadItem(songId: String, song: MeteorSong) {
        self.songId = songId

        // initialize a long-press action, here? I'm not sure.

        titleLabel.text = song.title
        descriptionLabel.text = song.annotation
        platformImageView.image = UIImage(named: song.platform.lowercaseString)
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
            switch(song.platform.lowercaseString){
            case "spotify":
                songArtworkView.image = UIImage(named: "spotify")
            case "soundcloud":
                songArtworkView.image = UIImage(named: "soundcloud")
            case "itunes":
                songArtworkView.image = UIImage(named: "itunes")
            default:
                fatalError()
            }
        }
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        (sender.on) ? PlaylistHandler.upvote(songId) : PlaylistHandler.downvote(songId)
    }
    
}