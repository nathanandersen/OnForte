//
//  SuggestedSongHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData

/**
 The SongHandler controls all of the songs in the application, whether in
 History, Playlist, Favorites, or Suggestions.
*/
class SongHandler: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    private static let playedSongCollection = PlaylistSongHistory(name: "playedSongs")
    private static let queuedSongs = SongCollection(name: "queueSongs")

    internal static func getPlaylistHistoryCount() -> Int {
        return playedSongCollection.count
    }

    internal static func getPlayedSongByIndex(index: Int) -> (String, PlayedSongDocument) {
        let songId = playedSongCollection.keys[index]
        return (songId, playedSongCollection.findOne(songId)!)
    }

    internal static func clearForNewPlaylist() {
        playedSongCollection.clear()
        queuedSongs.clear()
    }

    internal static func getSongsInQueue() -> [SongDocument] {
        return self.queuedSongs.sortedByScore()
    }

    internal static func getQueuedSongByIndex(index: Int) -> (String, SongDocument) {
        let songId = queuedSongs.keys[index]
        return (songId, queuedSongs.findOne(songId)!)
    }


    internal static func getTopSongWithPlatformConstraints(platforms: [Service]) -> Song? {
        print(platforms)
        let filteredSongs = getSongsInQueue().filter({
            platforms.contains(Service(platform: $0.platform))
        })
        if filteredSongs.count > 0 {
            return Song(songDoc: filteredSongs[0])
        } else {
            return nil
        }
    }





    internal static func insertIntoSuggestions(song: Song) {
        // if not in suggestions
        // insert



        SuggestedSong.createInManagedObjectContext(managedObjectContext, song: song)
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }

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