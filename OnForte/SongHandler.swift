//
//  SuggestedSongHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData

class SongHandler: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    internal static func fetchSuggestions() -> [Song] {
        let fetchRequest = NSFetchRequest(entityName: "SuggestedSong")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [SuggestedSong] {
            var songs = [Song]()
            fetchResults!.forEach({
                songs.append(Song(suggestedSong: $0))
            })
            return songs
        }
        return []
    }

    internal static func fetchFavorites() -> [Song] {
        let fetchRequest = NSFetchRequest(entityName: "FavoritedSong")

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [FavoritedSong] {
            var songs = [Song]()
            fetchResults!.forEach({songs.append(Song(favoritedSong: $0))})
            return songs
        }
        return []
    }
}