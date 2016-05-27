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
//    private var score: Int = 0

    @IBOutlet var songArtworkView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var platformImageView: UIImageView!
    @IBOutlet var scoreLabel: UILabel!

    @IBOutlet var stepper: UIStepper!

//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }

    internal func loadItem(songId: String, song: MeteorSong) {
        self.songId = songId

        // initialize a long-press action, here? I'm not sure.

        titleLabel.text = song.title
        descriptionLabel.text = song.annotation
        platformImageView.image = UIImage(named: song.platform.lowercaseString)
        stepper.value = Double(PlaylistHandler.getVotingStatus(songId).intValue())
        scoreLabel.text = String(song.score)
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


    @IBAction func stepperValueChanged(sender: UIStepper) {
        let votingStatus = PlaylistHandler.getVotingStatus(songId)
        if Int(sender.value) > votingStatus.intValue() {
            PlaylistHandler.upvote(songId)
        } else if Int(sender.value) < votingStatus.intValue() {
            PlaylistHandler.downvote(songId)
        } else {
            fatalError()
        }
    }
    
}