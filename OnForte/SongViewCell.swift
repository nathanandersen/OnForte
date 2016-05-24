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

    @IBOutlet var artworkView: UIImageView!
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var songDescriptionLabel: UILabel!
    @IBOutlet var platformImageView: UIImageView!

    /**
     The shared load item: set the title, description, etc.
    */
    private func sharedLoadItem(title: String?, description: String?, serviceString: String, artworkURL: NSURL?) {
        self.songTitleLabel.text = title
        self.songDescriptionLabel.text = description
        if let url = artworkURL {
            if url == "" {
                artworkView.image = UIImage(named: serviceString)
            } else {
                ArtworkHandler.lookupArtworkAsync(url, completionHandler: { (image: UIImage) in
                    self.artworkView.image = image
                    self.setNeedsLayout()
                })
            }
        }
        platformImageView.image = UIImage(named: serviceString)
    }


    /**
    Load a song into the cell.
     */
    internal func loadItem(song: Song) {
        self.sharedLoadItem(song.title, description: song.description, serviceString: String(song.service!).lowercaseString, artworkURL: song.artworkURL)
    }

    /**
     Load a MeteorSong into the cell
    */
    internal func loadItem(songId: String, song: MeteorSong) {
        self.sharedLoadItem(song.title, description: song.annotation, serviceString: song.platform.lowercaseString, artworkURL: NSURL(string: song.artworkURL!))
    }
    
}