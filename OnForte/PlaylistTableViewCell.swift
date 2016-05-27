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
    private var displayedSong: MeteorSong!

    @IBOutlet var songArtworkView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var platformImageView: UIImageView!
    @IBOutlet var scoreLabel: UILabel!

    @IBOutlet var stepper: UIStepper!


    internal func loadItem(songId: String, song: MeteorSong) {
        self.songId = songId
        self.displayedSong = song
        displaySong()

        // initialize a long-press action, here? I'm not sure.
    }

    internal func displaySong() {
        titleLabel.text = displayedSong.title
        descriptionLabel.text = displayedSong.annotation
        platformImageView.image = UIImage(named: displayedSong.platform.lowercaseString)
        stepper.value = Double(PlaylistHandler.getVotingStatus(songId).intValue())
        scoreLabel.text = String(displayedSong.score)
        if let url = displayedSong.artworkURL {
            ArtworkHandler.lookupArtworkAsync(NSURL(string: url)!, completionHandler: { (image: UIImage) in
                self.songArtworkView.image = image
                self.setNeedsLayout()
            })
        } else {
            switch(displayedSong.platform.lowercaseString){
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
        print("value changed")
/*        let votingStatus = PlaylistHandler.getVotingStatus(songId)
        if Int(sender.value) > votingStatus.intValue() {
            PlaylistHandler.upvote(songId, completionHandler: { _ in
                self.displaySong()
            })
        } else if Int(sender.value) < votingStatus.intValue() {
            PlaylistHandler.downvote(songId, completionHandler: { _ in
                self.displaySong()
            })
        } else {
            fatalError()
        }*/
    }
    
}