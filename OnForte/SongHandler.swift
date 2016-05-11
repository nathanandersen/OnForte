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

    private static func fetchSuggestionsAsOriginalData() -> [SuggestedSong] {
        let fetchRequest = NSFetchRequest(entityName: "SuggestedSong")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [SuggestedSong] {
            return fetchResults!
        }
        return []
    }

    internal static func fetchSuggestions() -> [Song] {
        let fetchResults = fetchSuggestionsAsOriginalData()
        var songs = [Song]()
        fetchResults.forEach({songs.append(Song(suggestedSong: $0))})
        return songs
    }

    internal static func removeItemFromSuggestions(song: Song) {
        var suggestedSong: SuggestedSong!
        for songItem in fetchSuggestionsAsOriginalData() {
            if Song(suggestedSong: songItem) == song {
                suggestedSong = songItem
                break
            }
        }
        managedObjectContext.deleteObject(suggestedSong)
        do {
            try managedObjectContext.save()
        } catch {
            print("save failed")
        }
    }

    internal static func removeItemFromFavorites(song: Song) {
        var favoritedSong: FavoritedSong!
        for songItem in fetchFavoritesAsOriginalData() {
            if Song(favoritedSong: songItem) == song {
                favoritedSong = songItem
                break
            }
        }
        managedObjectContext.deleteObject(favoritedSong)
        do {
            try managedObjectContext.save()
        } catch {
            print("save failed")
        }
    }

    private static func fetchFavoritesAsOriginalData() -> [FavoritedSong] {
        let fetchRequest = NSFetchRequest(entityName: "FavoritedSong")

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [FavoritedSong] {
            return fetchResults!
        }
        return []
    }

    internal static func fetchFavorites() -> [Song] {
        let fetchResults = fetchFavoritesAsOriginalData()
        var songs = [Song]()
        fetchResults.forEach({songs.append(Song(favoritedSong: $0))})
        return songs
    }
}