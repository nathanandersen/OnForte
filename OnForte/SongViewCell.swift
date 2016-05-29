//
//  SongViewCell.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
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

    @IBOutlet var favoritesStar: UIImageView!

    /**
    Load a song into the cell.
     */
    internal func loadItem(song: InternalSong) {
        self.songTitleLabel.text = song.title
        self.songDescriptionLabel.text = song.description
        if let url = song.artworkURL {
            if url == "" {
                artworkView.image = song.service!.getImage()
            } else {
                ArtworkHandler.lookupArtworkAsync(url, completionHandler: { (image: UIImage) in
                    self.artworkView.image = image
                    self.setNeedsLayout()
                })
            }
        }
        platformImageView.image = song.service!.getImage()

        if SongHandler.isSuggestion(song) || SongHandler.isFavorite(song) {
            favoritesStar.hidden = false
        } else {
            favoritesStar.hidden = true
        }

    }
    
}