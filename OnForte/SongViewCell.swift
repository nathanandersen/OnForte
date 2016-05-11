//
//  SongViewCell.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

/**
 SongViewCell is used in the PlaylistHistoryTable and in the SearchResultsTable.
 
 A simple construction, with album artwork on the left, title and description in the middle,
 and platform on the rigth
 */
class SongViewCell: UITableViewCell {

    var songTitleLabel: UILabel!
    var songDescriptionLabel: UILabel!
    var artworkView: UIImageView!
    var platformImageView: UIImageView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeTitleLabel()
        initializeDescriptionLabel()
        initializeArtwork()
        initializePlatform()
        initializeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("PlaylistHistoryTableViewCell does not support NSCoding")
    }

    /**
    Initialize the title label.
    */
    private func initializeTitleLabel() {
        songTitleLabel = Style.defaultLabel()
        songTitleLabel.textAlignment = .Left
        self.addSubview(songTitleLabel)
        songTitleLabel.backgroundColor = Style.clearColor
    }

    /**
    Initialize the description label
    */
    private func initializeDescriptionLabel() {
        songDescriptionLabel = Style.defaultLabel()
        songDescriptionLabel.textAlignment = .Left
        self.addSubview(songDescriptionLabel)
        songDescriptionLabel.backgroundColor = Style.clearColor
    }
    /**
    Initialize the platform image view.
    */
    private func initializePlatform() {
        platformImageView = UIImageView(image: UIImage(named: "spotify"))
        self.addSubview(platformImageView)
    }
    /**
    Initialize the artwork view
    */
    private func initializeArtwork() {
        artworkView = UIImageView()
        artworkView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(artworkView)
    }
    /** 
    Initialize all constraints
    */
    private func initializeConstraints() {
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        songDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        platformImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: artworkView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: artworkView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10).active = true
        NSLayoutConstraint(item: artworkView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70).active = true
        NSLayoutConstraint(item: artworkView, attribute: .Width, relatedBy: .Equal, toItem: artworkView, attribute: .Height, multiplier: 1, constant: 0).active = true


        NSLayoutConstraint(item: songTitleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -5).active = true
        NSLayoutConstraint(item: songTitleLabel, attribute: .Left, relatedBy: .Equal, toItem: artworkView, attribute: .Right, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: songTitleLabel, attribute: .Right, relatedBy: .Equal, toItem: platformImageView, attribute: .Left, multiplier: 1, constant: -5).active = true

        NSLayoutConstraint(item: songDescriptionLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: songDescriptionLabel, attribute: .Left, relatedBy: .Equal, toItem: artworkView, attribute: .Right, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: songDescriptionLabel, attribute: .Right, relatedBy: .Equal, toItem: platformImageView, attribute: .Left, multiplier: 1, constant: -5).active = true

        NSLayoutConstraint(item: platformImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: platformImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30).active = true
        NSLayoutConstraint(item: platformImageView, attribute: .Width, relatedBy: .Equal, toItem: platformImageView, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: platformImageView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -10).active = true

        songTitleLabel.updateConstraints()
        songDescriptionLabel.updateConstraints()
        platformImageView.updateConstraints()
        artworkView.updateConstraints()
    }

    /**
    Load a song into the cell.
     */
    internal func loadItem(song: Song) {
        self.songTitleLabel.text = song.title
        self.songDescriptionLabel.text = song.description
        let platformSource = String(song.service!).lowercaseString
        if let url = song.artworkURL {
            if url == "" {
                artworkView.image = UIImage(named: platformSource)
            } else {
                ArtworkHandler.lookupArtworkAsync(song.artworkURL!, completionHandler: { (image: UIImage) in
                    self.artworkView.image = image
                    self.setNeedsLayout()
                })
            }
        }
        platformImageView.image = UIImage(named: platformSource)
    }

    /**
     Load a MeteorSong into the cell
    */
    internal func loadItem(songId: String, song: MeteorSong) {
        self.songTitleLabel.text = song.title
        self.songDescriptionLabel.text = song.annotation
        let platformSource = song.platform.lowercaseString
        if let url = song.artworkURL {
            if url == "" {
                artworkView.image = UIImage(named: platformSource)
            } else {
                ArtworkHandler.lookupArtworkAsync(NSURL(string: url)!, completionHandler: { (image: UIImage) in
                    self.artworkView.image = image
                    self.setNeedsLayout()
                })
            }
        }
        platformImageView.image = UIImage(named: platformSource)
    }
    
}