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

    internal static func addSongToDatabase(song: Song) {
        // add the song
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