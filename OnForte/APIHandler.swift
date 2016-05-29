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

class Playlist: Hashable {
    var name: String
    var playlistId: String
    var _id: String
//    var isLoggedInToSpotify: Bool
//    var isLoggedInToSoundcloud: Bool
//    var isLoggedInToAppleMusic: Bool
    var createDate: NSDate

    init(jsonData: AnyObject) {
        print(jsonData)
        self._id = jsonData["_id"] as! String
        self.name = jsonData["name"]! as! String
        self.playlistId = jsonData["playlistId"]! as! String
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData["createDate"] as! String)!
    }

    var hashValue: Int {
        get {
            return self._id.hashValue
        }
    }
}

func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class APIHandler {

    internal static func convertJSONDateToNSDate(dateStr: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.dateFromString(dateStr)
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
                guard let playlists = response.result.value as? [AnyObject] else {
                    print("Malformed data received from fetchAllPlaylists service")
                    completion(nil)
                    return
                }
                var results = [Playlist]()
                playlists.forEach({results.append(Playlist(jsonData: $0))})
                completion(results)
            })
    }


/*    internal static func fetchAllSongs(completion: [Song]? -> ()) {
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

                guard let value = response.result.value as? [String:AnyObject],
                    // have to figure this out
                    rows = value["rows"] as? [[String:AnyObject]] else {
                        print("Malformed data received from fetchAllSongs service")
                        completion(nil)
                        return
                }

                var songs = [Song]()
                for song in rows {
                    print(song)
                }
                completion(songs)
            })
    }*/
}