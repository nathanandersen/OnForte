//
//  APIHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/29/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import Alamofire

let apiServer = "https://onforte-server.herokuapp.com"
let playlistsPath = "/playlists"
let songsPath = "/songs"
let songsByPlaylistIdPath = "/playlistsongs"


// use NSJSONSerialization class

class APIHandler {

    internal static func createPlaylist(playlist: PlaylistToInsert, completion: Playlist? -> ()) {

        let request = NSMutableURLRequest(URL: NSURL(string: apiServer + playlistsPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = playlist.toJSON()
        Alamofire.request(request).validate()
            .responseJSON(completionHandler: {
                response in
                guard response.result.isSuccess else {
                    print("Error while adding playlist: \(response.result.error)")
                    completion(nil)
                    return
                }
                if let obj = response.result.value {
                    // comes back as a full Playlist

                    completion(Playlist(jsonData: obj))
                } else {
                    completion(nil)
                }
            })
    }




    // when doing upvote/downvote
    // pass in entire object, I think?

    // could be done with update -> $set
    // but I think this could be cleaner


    internal static func convertJSONDateToNSDate(dateStr: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(dateStr)
    }

    internal static func updateSongs() {
        print("Update songs was called.")
        fetchAllSongsInPlaylist() {
            (result: [Song]?) in
            if let results = result {
                results.forEach({
                    if let coreDataId = SongHandler.managedObjectIDForMongoID($0._id) {
                        SongHandler.updateScoreValue(coreDataId, score: $0.score)
                    } else {
                        SongHandler.insertIntoQueue($0)
                    }
                })
            }

            // save all core data
            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
            // reload the playlist data table
            NSNotificationCenter.defaultCenter().postNotificationName(reloadTableKey, object: nil)
        }
    }

    internal static func addSongToDatabase(song: SearchSong, completion: Song? -> ()) {
        // it goes in as a SearchSong

        let request = NSMutableURLRequest(URL: NSURL(string: apiServer + songsPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = song.toJSON()


        Alamofire.request(request).validate()
            .responseJSON(completionHandler: {
                response in
                guard response.result.isSuccess else {
                    print("Error while adding song: \(response.result.error)")
                    completion(nil)
                    return
                }
                if let obj = response.result.value {
                    // comes back as a full Song

                    // insert the song to CoreData
                    completion(Song(jsonData: obj))
                } else {
                    completion(nil)
                }

        })
    }

    internal static func fetchAllPlaylists(completion: [Playlist]? -> ()) {
        Alamofire.request(
            .GET,
            apiServer + playlistsPath,
            parameters: nil,
            encoding: .URL,
            headers: nil).validate().responseJSON(completionHandler: {
                response -> () in
                guard response.result.isSuccess else {
                    print("Error while fetching songs: \(response.result.error)")
                    completion(nil)
                    return
                }
                guard let results = response.result.value as? [AnyObject] else {
                    print("Malformed data received from fetchAllPlaylists service")
                    completion(nil)
                    return
                }
                var playlists = [Playlist]()
                results.forEach({playlists.append(Playlist(jsonData: $0))})
                completion(playlists)
            })
    }

    private static func fetchAllSongsInPlaylist(completion: [Song]? -> ()) {
        Alamofire.request(
            .GET,
            apiServer + songsByPlaylistIdPath + "/" + PlaylistHandler.playlist!.playlistId,
            parameters: nil,
            encoding: .URL,
            headers: nil).validate().responseJSON(completionHandler: {
                (response) -> () in
                guard response.result.isSuccess else {
                    print("Error while fetching songs: \(response.result.error)")
                    completion(nil)
                    return
                }

                guard let results = response.result.value as? [AnyObject] else {
                    print("Malformed data received from fetchAllSongs service")
                    completion(nil)
                    return
                }
                var songs = [Song]()
                results.forEach({songs.append(Song( jsonData: $0))})
                completion(songs)
            })
    }


/*    private static func fetchAllSongs(completion: [Song]? -> ()) {
        Alamofire.request(
            .GET,
            apiServer + songsPath,
            parameters: nil,
            encoding: .URL,
            headers: nil).validate().responseJSON(completionHandler: {
                (response) -> () in
                guard response.result.isSuccess else {
                    print("Error while fetching songs: \(response.result.error)")
                    completion(nil)
                    return
                }

                guard let results = response.result.value as? [AnyObject] else {
                    print("Malformed data received from fetchAllSongs service")
                    completion(nil)
                    return
                }
                var songs = [Song]()
                results.forEach({songs.append(Song( jsonData: $0))})
                completion(songs)
            })
    }*/
}