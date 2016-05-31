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


let equalFormat = "%K == %@"
/**
 The SongHandler controls all of the songs in the application, whether in
 History, Playlist, Favorites, or Suggestions.
*/
class SongHandler: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    private static var appleMusicSongs = MPMediaQuery.songsQuery().items
    private static var mappedAppleMusicSongs: [SearchSong] = {
        var songs = [SearchSong]()
        if appleMusicSongs!.count > 0 {
            for i in 0...(appleMusicSongs!.count-1){
                let track = appleMusicSongs![i]
                songs.append(SearchSong(
                    title: track.title,
                    annotation: track.albumTitle,
                    musicPlatform: .AppleMusic,
                    artworkURL: nil,
                    trackId: String(i)))
            }
        }
        return songs
    }()


    private static var idDictionary = [String:NSManagedObjectID]()

    internal static func managedObjectIDForMongoID(songId: String) -> NSManagedObjectID? {
        return idDictionary[songId]
    }

    internal static func getQueuedSongs() -> [QueuedSong] {
        let fetchRequest = NSFetchRequest(entityName: "QueuedSong")
        let playlistIdPredicate = NSPredicate(format: equalFormat, playlistIdKey, PlaylistHandler.playlist!.playlistId)
        let queuePredicate = NSPredicate(format: equalFormat, activeStatusKey, NSNumber(integer: ActiveStatus.Queue.rawValue))
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [playlistIdPredicate,queuePredicate])

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: scoreKey, ascending: false)]
        // fetch request sort?

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [QueuedSong] {
//            return fetchResults!.sort({$0.score!.intValue >= $1.score!.intValue})
            return fetchResults!

            // sort this by score
        }
        return []
    }

    internal static func getActiveSong() -> QueuedSong? {
        let fetchRequest = NSFetchRequest(entityName: "QueuedSong")
        let playlistIdPredicate = NSPredicate(format: equalFormat, playlistIdKey, PlaylistHandler.playlist!.playlistId)
        let nowPlayingPredicate = NSPredicate(format: equalFormat, activeStatusKey, NSNumber(integer: ActiveStatus.NowPlaying.rawValue))
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [playlistIdPredicate,nowPlayingPredicate])

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [QueuedSong] {
            return fetchResults?[0]
        }
        return nil
    }

    internal static func getHistorySongs() -> [QueuedSong] {
        let fetchRequest = NSFetchRequest(entityName: "QueuedSong")
        let playlistIdPredicate = NSPredicate(format: equalFormat, playlistIdKey, PlaylistHandler.playlist!.playlistId)
        let historyPredicate = NSPredicate(format: equalFormat, activeStatusKey, NSNumber(integer: ActiveStatus.History.rawValue))
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [playlistIdPredicate,historyPredicate])

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [QueuedSong] {
            return fetchResults!

            // maybe we should sort this by CreateDate
            // but that has to do with regards to when it was updated
            // not when it was played

        }
        return []
    }

    internal static func insertIntoQueue(song: Song) {
        let item = QueuedSong.createInManagedObjectContext(managedObjectContext, song: song)
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        idDictionary[song._id] = item.objectID
        // create the item in Core Data
        // add its association in the idDictionary

    }

    internal static func updateItem(songId: NSManagedObjectID, song: Song) {
        let item = managedObjectContext.objectWithID(songId)
        item.setValue(song.score, forKey: scoreKey)
        item.setValue(song.activeStatus.rawValue, forKey: activeStatusKey)
    }

    internal static func getSongByArrayIndex(index: Int) -> MPMediaItem? {
        if appleMusicSongs == nil {
            return nil
        }
        return appleMusicSongs![index]
    }

    internal static func getLocalSongsByQuery(query: String) -> [SearchSong]? {
        if query == "" {
            return nil
        }
        return mappedAppleMusicSongs.filter({
            return (
                (($0.title != nil) ?
                    ($0.title! as NSString).rangeOfString(query,options: NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound :
                    false) ||
                (($0.annotation != nil) ?
                    ($0.annotation! as NSString).rangeOfString(query,options: NSStringCompareOptions.CaseInsensitiveSearch).location != NSNotFound  :
                    false))
        })
    }

    /**
     Wipe the songs for the next playlist
    */
    internal static func clearForNewPlaylist() {
        let fetchRequest = NSFetchRequest(entityName: "QueuedSong")
        fetchRequest.includesPropertyValues = false
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [QueuedSong] {
            for item in fetchResults! {
                managedObjectContext.deleteObject(item)
            }
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("save failed")
        }
    }

    /**
     Get the top song according to the platform constraints
    */
    internal static func getTopSongWithPlatformConstraints(musicPlatforms: Set<MusicPlatform>) -> QueuedSong? {
        return getQueuedSongs().filter({musicPlatforms.contains(MusicPlatform(str: $0.musicPlatform!))}).first
    }

    internal static func isFavorite(song: SearchSong) -> Bool {
        for favorite in fetchFavorites() {
            if song == favorite {
                return true
            }
        }
        return false
    }

    internal static func isSuggestion(song: SearchSong) -> Bool {
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
    internal static func insertIntoSuggestions(song: SearchSong) {
        if song.musicPlatform == .AppleMusic {
            return
        }
            // currently, we don't save local music suggestions.
        var suggestedSong: SuggestedSong?
        for songItem in fetchSuggestionsAsOriginalData() {
            if SearchSong(title: songItem.title, annotation: songItem.annotation, musicPlatform: MusicPlatform(str: (songItem.service?.lowercaseString)!), artworkURL: NSURL(string: songItem.artworkURL!), trackId: songItem.trackId!) == song {
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
     Conditionally insert into favorites if not already there
     */
    internal static func insertIntoFavorites(song: SearchSong) {
        var favoritedSong: FavoritedSong?
        for songItem in fetchFavoritesAsOriginalData() {

            if SearchSong(title: songItem.title, annotation: songItem.annotation, musicPlatform: MusicPlatform(str: (songItem.service?.lowercaseString)!), artworkURL: NSURL(string: songItem.artworkURL!), trackId: songItem.trackId!) == song {
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
     Fetch the suggestions as an array of SearchSong
    */
    internal static func fetchSuggestions() -> [SearchSong] {
        let fetchResults = fetchSuggestionsAsOriginalData()
        var songs = [SearchSong]()
        fetchResults.forEach({
            songs.append(SearchSong(title: $0.title, annotation: $0.annotation, musicPlatform: MusicPlatform(str: $0.service!), artworkURL: NSURL(string: $0.artworkURL!), trackId: $0.trackId!))
        })
        return songs
    }

    /**
     Remove an item from suggestions
    */
    internal static func removeItemFromSuggestions(song: SearchSong) {
        var suggestedSong: SuggestedSong!
        for songItem in fetchSuggestionsAsOriginalData() {
            if song == SearchSong(title: songItem.title, annotation: songItem.annotation, musicPlatform: MusicPlatform(str: songItem.service!), artworkURL: NSURL(string: songItem.artworkURL!), trackId: songItem.trackId!) {
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
    internal static func removeItemFromFavorites(song: SearchSong) {
        var favoritedSong: FavoritedSong!
        for songItem in fetchFavoritesAsOriginalData() {
            if song == SearchSong(title: songItem.title, annotation: songItem.annotation, musicPlatform: MusicPlatform(str: songItem.service!), artworkURL: NSURL(string: songItem.artworkURL!), trackId: songItem.trackId!) {
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
     Fetch the favorites as an array of SearchSong
    */
    internal static func fetchFavorites() -> [SearchSong] {
        let fetchResults = fetchFavoritesAsOriginalData()
        var songs = [SearchSong]()
        fetchResults.forEach({
            songs.append(SearchSong(title: $0.title, annotation: $0.annotation, musicPlatform: MusicPlatform(str: $0.service!), artworkURL: NSURL(string: $0.artworkURL!), trackId: $0.trackId!))
        })
        return songs
    }
}