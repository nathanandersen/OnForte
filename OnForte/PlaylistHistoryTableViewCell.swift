//
//  SongHistoryViewCell.swift
//  Forte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation


class PlaylistHistoryTableViewCell: UITableViewCell {

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

    func initializeTitleLabel() {
        songTitleLabel = Style.defaultLabel()
        songTitleLabel.textAlignment = .Left
        self.addSubview(songTitleLabel)
        songTitleLabel.backgroundColor = Style.clearColor
    }

    func initializeDescriptionLabel() {
        songDescriptionLabel = Style.defaultLabel()
        songDescriptionLabel.textAlignment = .Left
        self.addSubview(songDescriptionLabel)
        songDescriptionLabel.backgroundColor = Style.clearColor
    }

    func initializePlatform() {
        platformImageView = UIImageView(image: UIImage(named: "spotify"))
        self.addSubview(platformImageView)
    }

    func initializeArtwork() {
        artworkView = UIImageView()
        self.addSubview(artworkView)
    }

    func initializeConstraints() {
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
    
    func loadItem(songId: String, song: MeteorSong) {
        self.songTitleLabel.text = song.title
        self.songDescriptionLabel.text = song.annotation
        let platformSource = song.platform.lowercaseString
        if let url = song.artworkURL {
            if url == "" {
                artworkView.image = UIImage(named: platformSource)
            } else {
                artworkHandler.lookupForCell(NSURL(string: url)!,imageView: artworkView,cell: self)
            }
        }
        platformImageView.image = UIImage(named: platformSource)
    }
    
}