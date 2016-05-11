//
//  SuggestedSongHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

/**
 The SongHandler controls all of the songs in the application, whether in
 History, Playlist, Favorites, or Suggestions.
*/
class SongHandler: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext


    internal static var allLocalITunes: [Song] = {
        var songs = [Song]()
        if allLocalITunesOriginals!.count > 0 {
            for i in 0...(allLocalITunesOriginals!.count-1){
                let track = allLocalITunesOriginals![i]
                let song = Song(
                    title: track.title,
                    description: track.albumTitle,
                    service: Service.iTunes,
                    trackId: String(i),
                    artworkURL: nil)
                songs += [song]
            }
        }
        return songs
    }()

    internal static var allLocalITunesOriginals: [MPMediaItem]? = MPMediaQuery.songsQuery().items

    /**
     Manage the playlist history
    */
    private static let playedSongCollection = PlaylistSongHistory(name: "playedSongs")
    /**
     Manage the active queue
    */
    private static let queuedSongs = SongCollection(name: "queueSongs")

    /**
     Get the number of songs in the playlist history
    */
    internal static func getPlaylistHistoryCount() -> Int {
        return playedSongCollection.count
    }

    /**
     Given an index into the Playlist History, return a tuple of that song's ID and the song.
    */
    internal static func getPlayedSongByIndex(index: Int) -> (String, PlayedSongDocument) {
        let songId = playedSongCollection.keys[index]
        return (songId, playedSongCollection.findOne(songId)!)
    }

    /**
     Wipe the songs for the next playlist
    */
    internal static func clearForNewPlaylist() {
        playedSongCollection.clear()
        queuedSongs.clear()
    }

    /**
     Get a sorted array of the songs in the queue
    */
    internal static func getSongsInQueue() -> [SongDocument] {
        return self.queuedSongs.sortedByScore()
    }
    /**
     Given an index into the Playlist Queue, return a tuple of that song's ID and the song.
     */
    internal static func getQueuedSongByIndex(index: Int) -> (String, SongDocument) {
        let songId = queuedSongs.keys[index]
        return (songId, queuedSongs.findOne(songId)!)
    }

    /**
     Get the top song according to the platform constraints
    */
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


    /**
     Conditionally insert into suggestions if not already there
    */
    internal static func insertIntoSuggestions(song: Song) {
        var suggestedSong: SuggestedSong?
        for songItem in fetchSuggestionsAsOriginalData() {
            if Song(suggestedSong: songItem) == song {
                suggestedSong = songItem
                break
            }
        }
        if suggestedSong == nil {
            SuggestedSong.createInManagedObjectContext(managedObjectContext, song: song)
            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        }
    }

    /**
     Conditionally insert into favorties if not already there
     */
    internal static func insertIntoFavorites(song: Song) {
        var favoritedSong: FavoritedSong?
        for songItem in fetchFavoritesAsOriginalData() {
            if Song(favoritedSong: songItem) == song {
                favoritedSong = songItem
                break
            }
        }
        if favoritedSong == nil {
            FavoritedSong.createInManagedObjectContext(managedObjectContext, song: song)
            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        }
    }

    /**
     Fetch the suggestions as an array of SuggestedSong
    */
    private static func fetchSuggestionsAsOriginalData() -> [SuggestedSong] {
        let fetchRequest = NSFetchRequest(entityName: "SuggestedSong")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [SuggestedSong] {
            return fetchResults!
        }
        return []
    }

    /**
     Fetch the suggestions as an array of Song
    */
    internal static func fetchSuggestions() -> [Song] {
        let fetchResults = fetchSuggestionsAsOriginalData()
        var songs = [Song]()
        fetchResults.forEach({songs.append(Song(suggestedSong: $0))})
        return songs
    }

    /**
     Remove an item from suggestions
    */
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

    /**
     Remove an item from favorites
    */
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

    /**
     Fetch the favorites as an array of FavoritedSong (a Core Data item)
    */
    private static func fetchFavoritesAsOriginalData() -> [FavoritedSong] {
        let fetchRequest = NSFetchRequest(entityName: "FavoritedSong")

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [FavoritedSong] {
            return fetchResults!
        }
        return []
    }

    /**
     Fetch the favorites as an array of Song
    */
    internal static func fetchFavorites() -> [Song] {
        let fetchResults = fetchFavoritesAsOriginalData()
        var songs = [Song]()
        fetchResults.forEach({songs.append(Song(favoritedSong: $0))})
        return songs
    }
}