//
//  SuggestedSongHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
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
    private static var appleMusicSongs = MPMediaQuery.songsQuery().items
    private static var mappedAppleMusicSongs: [InternalSong] = {
        var songs = [InternalSong]()
        if appleMusicSongs!.count > 0 {
            for i in 0...(appleMusicSongs!.count-1){
                let track = appleMusicSongs![i]
                let song = InternalSong(
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


    private static var idDictionary = [String:NSManagedObjectID]()

    internal static func managedObjectIDForMongoID(songId: String) -> NSManagedObjectID? {
        return idDictionary[songId]
    }

    internal static func getQueuedSongs() -> [Song] {
        let fetchRequest = NSFetchRequest(entityName: "QueuedSong")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [Song] {
            return fetchResults!
        }
        return []
    }

    internal static func getQueuedSongsAsSet() -> Set<Song> {
        return Set(getQueuedSongs())
    }

    internal static func insertIntoQueue(song: Song) {
        PlaylistHandler.addVotingStatusForId(song._id)
        idDictionary[song._id] = QueuedSong.createInManagedObjectContext(managedObjectContext, song: song).objectID
        // create the item in Core Data
        // add its association in the idDictionary

        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }

    internal static func updateScoreValue(songId: NSManagedObjectID, score: Int) {
        var item = managedObjectContext.objectWithID(songId)
        item.setValue(score, forKey: scoreKey)
        // hmmm...
        //        managedObjectContext.objectWithID() 
        //this looks interesting
    }


    internal static func getSongByArrayIndex(index: Int) -> MPMediaItem? {
        if appleMusicSongs == nil {
            return nil
        }
        return appleMusicSongs![index]
    }

    internal static func getLocalSongsByQuery(query: String) -> [InternalSong]? {
        if query == "" {
            return nil
        }
        return mappedAppleMusicSongs.filter({
            return (
                (($0.title != nil) ?
                    ($0.title! as NSString).rangeOfString(query,options: NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound :
                    false) ||
                (($0.description != nil) ?
                    ($0.description! as NSString).rangeOfString(query,options: NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound  :
                    false))
        })
    }

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
    internal static func getTopSongWithPlatformConstraints(platforms: [Service]) -> InternalSong? {
        let filteredSongs = getSongsInQueue().filter({
            platforms.contains(Service(platform: $0.platform))
        })
        if filteredSongs.count > 0 {
            return InternalSong(songDoc: filteredSongs[0])
        } else {
            return nil
        }
    }

    internal static func isFavorite(song: InternalSong) -> Bool {
//        return Set(fetchFavorites()).contains(song)

        for favorite in fetchFavorites() {
            if song == favorite {
                return true
            }
        }
        return false
    }

    internal static func isSuggestion(song: InternalSong) -> Bool {
//        return Set(fetchSuggestions()).contains(song)
        for suggestion in fetchSuggestions() {
            if song == suggestion {
                return true
            }
        }
        return false
    }


    /**
     Conditionally insert into suggestions if not already there
    */
    internal static func insertIntoSuggestions(song: InternalSong) {
        if song.service! == .iTunes {
            // currently, we don't save local music suggestions.
            return
        }
        var suggestedSong: SuggestedSong?
        for songItem in fetchSuggestionsAsOriginalData() {
            if InternalSong(suggestedSong: songItem) == song {
                suggestedSong = songItem
                break
            }
        }
        if suggestedSong != nil {
            return
        }
        SuggestedSong.createInManagedObjectContext(managedObjectContext, song: song)
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }

    /**
     Conditionally insert into favorties if not already there
     */
    internal static func insertIntoFavorites(song: InternalSong) {
        var favoritedSong: FavoritedSong?
        for songItem in fetchFavoritesAsOriginalData() {
            if InternalSong(favoritedSong: songItem) == song {
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
    internal static func fetchSuggestions() -> [InternalSong] {
        let fetchResults = fetchSuggestionsAsOriginalData()
        var songs = [InternalSong]()
        fetchResults.forEach({songs.append(InternalSong(suggestedSong: $0))})
        return songs
    }

    /**
     Remove an item from suggestions
    */
    internal static func removeItemFromSuggestions(song: InternalSong) {
        var suggestedSong: SuggestedSong!
        for songItem in fetchSuggestionsAsOriginalData() {
            if InternalSong(suggestedSong: songItem) == song {
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
    internal static func removeItemFromFavorites(song: InternalSong) {
        var favoritedSong: FavoritedSong!
        for songItem in fetchFavoritesAsOriginalData() {
            if InternalSong(favoritedSong: songItem) == song {
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
    internal static func fetchFavorites() -> [InternalSong] {
        let fetchResults = fetchFavoritesAsOriginalData()
        var songs = [InternalSong]()
        fetchResults.forEach({songs.append(InternalSong(favoritedSong: $0))})
        return songs
    }
}