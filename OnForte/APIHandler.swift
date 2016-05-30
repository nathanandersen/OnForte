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
let upvotePath = "/upvote"
let downvotePath = "/downvote"
let upvoteIdKey = "id"

enum APIRequest {
    case Playlists
    case Songs
    case SongsInPlaylist
    case Upvote
    case Downvote

    internal func getAPIURL() -> NSURL {
        if self == .Playlists {
            return NSURL(string: apiServer + playlistsPath)!
        } else if self == .Songs {
            return NSURL(string: apiServer + songsPath)!
        } else if self == .SongsInPlaylist {
            return NSURL(string: apiServer + songsByPlaylistIdPath)!
        } else if self == .Upvote {
            return NSURL(string: apiServer + upvotePath)!
        } else if self == .Downvote {
            return NSURL(string: apiServer + downvotePath)!
        } else {
            fatalError()
        }
    }
}


// use NSJSONSerialization class

class APIHandler {

    internal static func convertJSONDateToNSDate(dateStr: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(dateStr)
    }

    internal static func createPlaylist(playlist: PlaylistToInsert, completion: Playlist? -> ()) {
        let request = NSMutableURLRequest(URL: APIRequest.Playlists.getAPIURL())
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

    internal static func upvoteSong(id: String, completion: Bool -> ()) {
        let request = NSMutableURLRequest(URL: APIRequest.Upvote.getAPIURL())
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject([upvoteIdKey:id], options: [])

        Alamofire.request(request).validate()
            .responseJSON(completionHandler: {
                response in
                guard response.result.isSuccess else {
                    print("Error while upvoting song: \(response.result.error)")
                    completion(false)
                    return
                }
                completion(true)
            })
        // flesh this out
    }

    internal static func downvoteSong(id: String, completion: Bool -> ()) {
        let request = NSMutableURLRequest(URL: APIRequest.Downvote.getAPIURL())
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject([upvoteIdKey:id], options: [])

        Alamofire.request(request).validate()
            .responseJSON(completionHandler: {
                response in
                guard response.result.isSuccess else {
                    print("Error while downvoting song: \(response.result.error)")
                    completion(false)
                    return
                }
                completion(true)
            })
    }



    internal static func updateSongs() {
        fetchAllSongsInPlaylist() {
            (result: [Song]?) in
            if let results = result {
                results.forEach({
                    if let coreDataId = SongHandler.managedObjectIDForMongoID($0._id) {
                        SongHandler.updateItem(coreDataId, song: $0)
                    } else {
                        SongHandler.insertIntoQueue($0)
                    }
                })
            }

            // save all core data
            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
            // reload the playlist data table
            NSNotificationCenter.defaultCenter().postNotificationName(reloadTableKey, object: nil)

            // reload the player
            // reload the history table
        }
    }

    internal static func addSongToDatabase(song: SearchSong, completion: Song? -> ()) {
        // it goes in as a SearchSong

        let request = NSMutableURLRequest(URL: APIRequest.Songs.getAPIURL())
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
            String(APIRequest.Playlists.getAPIURL()),
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
            String(APIRequest.SongsInPlaylist.getAPIURL()) + "/" + PlaylistHandler.playlist!.playlistId,
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