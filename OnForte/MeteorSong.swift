//
//  MeteorSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

protocol MeteorSong {

    var collection:String { get set }
    var _id: String { get set }
    var playlistId: String { get set }
    var title: String { get set }
    var annotation: String? { get set }
    var artworkURL: String? { get set }
    var platform: String { get set }
    var score: Int { get set }
    var trackId: String { get set }
}