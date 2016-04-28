//
//  SongTableViewCell.swift
//  Forte
//
//  Created by Nathan Andersen on 3/20/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import UIKit
import SwiftDDP
import SWTableViewCell

class SongTableViewCell: SWTableViewCell {

    @IBOutlet var titleLabelView: UIView!
    @IBOutlet var descriptionLabelView: UIView!
    @IBOutlet var scoreLabelView: UIView!
    
    var titleLabel: UILabel?
    var descriptionLabel: UILabel?
    var scoreLabel: UILabel?
    
    @IBOutlet var songImage: UIImageView!
    @IBOutlet var platformImage: UIImageView!
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    
//    var song: SongDocument!
    var song: MeteorSong!
    var songId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        renderTitleLabel()
        renderDescriptionLabel()
        renderScoreLabel()
    }
    
    func renderScoreLabel() {
        let label = Style.defaultLabel()
        label.font = Style.defaultFont(15)
        scoreLabelView.addSubview(label)
        
        let constraints = Style.constrainToBoundsOfFrame(label, parentView: scoreLabelView)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
        scoreLabel = label
    }
    
    func renderTitleLabel() {
        let label = Style.defaultLabel()
        label.textAlignment = .Left
        titleLabelView.addSubview(label)
        titleLabelView.backgroundColor = Style.clearColor
        
        let constraints = Style.constrainToBoundsOfFrame(label, parentView: titleLabelView)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
        titleLabel = label
    }
    
    func renderDescriptionLabel() {
        let label = Style.defaultLabel()
        label.backgroundColor = Style.clearColor
        label.textAlignment = .Left
        label.font = Style.defaultFont(10)
        descriptionLabelView.addSubview(label)
        descriptionLabelView.backgroundColor = Style.clearColor
        
        let constraints = Style.constrainToBoundsOfFrame(label, parentView: descriptionLabelView)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
        
        descriptionLabel = label
    }
    
    func reloadTable(result: AnyObject?,error:DDPError?) {
        // find a way to time this... it's out of sync w/ call?
        NSNotificationCenter.defaultCenter().postNotificationName("updateTable", object: nil)
//        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
    }

    @IBAction func upvoteClicked(sender: AnyObject) {
        let key = song._id
//        let key = SongVotingKey(doc: song)
        if votes[key]! != VotingStatus.Upvote {
            let newVotingStatus = votes[key]!.upvote()
            displayVotingStatus(newVotingStatus)
            votes[key] = newVotingStatus
            Meteor.call("upvoteSong",params:[songId],callback: self.reloadTable)
        }
        
    }

    @IBAction func downvoteClicked(sender: AnyObject) {
        let key = song._id
//        let key = SongVotingKey(doc: song)
        if votes[key]! != VotingStatus.Downvote {
            let newVotingStatus = votes[key]!.downvote()
            displayVotingStatus(newVotingStatus)
            votes[key] = newVotingStatus
            Meteor.call("downvoteSong",params:[songId],callback: self.reloadTable)
        }
    }
    
/*    func loadItem(songId: String, song: SongDocument) {
        self.songId = songId
        self.song = song
        self.render()
    }*/
    func loadItem(songId: String, song: MeteorSong) {
        self.songId = songId
        self.song = song
        self.render()
    }

/*    func loadItem(songId: String, song: PlayedSongDocument) {
        self.songId = songId
        self.song = song
        self.render()
    }*/

    func render() {
        titleLabel!.text = song.title
        descriptionLabel!.text = song.annotation
        scoreLabel!.text = String(song.score)
        let platformSource = song.platform.lowercaseString
        if let url = song.artworkURL {
            if url == "" {
                switch(song.platform.lowercaseString){
                case "spotify":
                    songImage.image = UIImage(named: "spotify")
                case "soundcloud":
                    songImage.image = UIImage(named: "soundcloud")
                case "itunes":
                    songImage.image = UIImage(named: "itunes")
                default:
                    break
                }
            }
            else {
                artworkHandler.lookupForCell(NSURL(string: url)!,imageView: songImage,cell: self)
            }
        }
        else {
            print(song.platform.lowercaseString)
            
            
            
        }
        platformImage.image = UIImage(named: platformSource)
        let key = song._id
//        let key = SongVotingKey(doc: song)
        displayVotingStatus(votes[key]!)
    }

    func displayVotingStatus(votingStatus: VotingStatus) {
        switch(votingStatus) {
        case .Upvote:
            upvoteButton.setTitleColor(Style.blackColor, forState: .Normal)
            downvoteButton.setTitleColor(Style.lightGrayColor, forState: .Normal)
        case .Downvote:
            upvoteButton.setTitleColor(Style.lightGrayColor, forState: .Normal)
            downvoteButton.setTitleColor(Style.blackColor, forState: .Normal)
        case .None:
            upvoteButton.setTitleColor(Style.lightGrayColor, forState: .Normal)
            downvoteButton.setTitleColor(Style.lightGrayColor, forState: .Normal)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
