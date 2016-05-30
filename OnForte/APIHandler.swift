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
// use NSJSONSerialization class

class APIHandler {

    internal static func convertJSONDateToNSDate(dateStr: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(dateStr)
    }

    internal static func updateSongs() {
        Alamofire.request(
            .GET,
            apiServer + "/songs",
            parameters: nil,
            encoding: .URL,
            headers: nil).validate().responseJSON(completionHandler: {
                (response) -> () in
                guard response.result.isSuccess else {
                    print("Error while fetching songs: \(response.result.error)")
//                    completion(nil)
                    return
                }

                guard let results = response.result.value as? [AnyObject] else {
                    print("Malformed data received from fetchAllSongs service")
//                    completion(nil)
                    return
                }

                let queue = SongHandler.getQueuedSongsAsSet()
//                var songs = [Song]()
                results.forEach({
                    let song = Song(jsonData: $0)
                    if queue.contains(song) {
                        // update score value
                    } else {
                        SongHandler.insertIntoQueue(song)
                        // this takes care of Core Data and Voting Status
                    }
                })

                // reload the playlist data table
                NSNotificationCenter.defaultCenter().postNotificationName(reloadTableKey, object: nil)
            })


        // where updateSongs() performs a new HTTP GET on /playlistsongs
        //, then compares each one to see...
        // if exists {
        //  check score for update
        // } else {
        // insert anew
        // }

        // post the notification to update the Playlist table
    }

    internal static func addSongToDatabase(song: SearchSong, completion: Song? -> ()) {
        // it goes in as a SearchSong

        let request = NSMutableURLRequest(URL: NSURL(string: apiServer + "/songs")!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(song.toDictionary(), options: [])

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
                    // give it a new VotingStatus object, intialized to None

                    completion(Song(jsonData: obj))
                }
                completion(nil)

        })
    }

    internal static func fetchAllPlaylists(completion: [Playlist]? -> ()) {
        Alamofire.request(
            .GET,
            apiServer + "/playlists",
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


    internal static func fetchAllSongs(completion: [Song]? -> ()) {
        Alamofire.request(
            .GET,
            apiServer + "/songs",
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
}