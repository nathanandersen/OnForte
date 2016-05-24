//
//  IntegratedMusicPlayer.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/16/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation
import SwiftDDP

/**
 IntegratedMusicPlayer is a 3-piece integrated music player that brings together the playing
 capabilities of Spotify, SoundCloud, and local music stored on your phone.
 
 */
class IntegratedMusicPlayer: NSObject, AVAudioPlayerDelegate, SPTAudioStreamingPlaybackDelegate {

    var spotifyPlayer: SPTAudioStreamingController
    var soundcloudPlayer: AVAudioPlayer?
    var localPlayer: MPMusicPlayerController
    var playlistController: PlaylistController!
    var control: MusicPlayerView!

    var playing: Bool

    override init() {
        spotifyPlayer = SPTAudioStreamingController.init(clientId: SPTAuth.defaultInstance().clientID)
        localPlayer = MPMusicPlayerController.applicationMusicPlayer()
        playing = false
        super.init()
        spotifyPlayer.playbackDelegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IntegratedMusicPlayer.handlePlaybackStateChanged(_:)), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: self.localPlayer)
        localPlayer.beginGeneratingPlaybackNotifications()
    }

    /**
     A function to toggle the playing status of the player.
     */
    func togglePlayingStatus(completionHandler: Bool -> Void) {
        if let currentSong = PlaylistHandler.nowPlaying {
            switch(currentSong.service!) {
            case .Soundcloud:
                if playing {
                    soundcloudPlayer?.pause()
                } else {
                    soundcloudPlayer?.play()
                }
            case .Spotify:
                spotifyPlayer.setIsPlaying(!playing,callback: nil)
            case .iTunes:
                playing ? localPlayer.pause() : localPlayer.play()
            }
            playing = !playing
            completionHandler(playing)
        } else {
            PlaylistHandler.playNextSong({(result) in
                completionHandler(result)
                self.playing = result
            })
        }
    }

    internal func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        songEnded()
    }

    /**
     This function calls the necessary Meteor methods in order to properly register
     the next song with the server.
     
     - parameters: 
        - song: the song that will be registered on the server
     
     - attention: Meteor Methods:
     registerSongAsPlayed: add the song to the PlayedSongs database
     removeSongFromQueue: remove the song from the QueueSongs database
     setSongAsPlaying: add the song as now playing to the Playlists database
    */
    private func registerNextSongWithServer(song: Song ) {
        let paramObj = [PlaylistHandler.playlistId,
                        (song.title != nil) ? song.title! : "",
                        (song.description != nil) ? song.description! : "",
                        String(song.service!),
                        (song.trackId != nil) ? song.trackId! : "",
                        (song.artworkURL != nil) ? String(song.artworkURL!) : ""]

        Meteor.call("registerSongAsPlayed",params: paramObj,callback: nil)
        Meteor.call("removeSongFromQueue",params: [song.id!],callback: nil)

        let songParamObj: [AnyObject] = [PlaylistHandler.playlistId,song.getSongDocFields()]
        Meteor.call("setSongAsPlaying",params: songParamObj,callback: nil)
    }

    /**
     This function gets the next song from the playlist controller, then tries to play it, calling
     the other methods in this class depending on the platform.
     
     It also tells the iPhone that music is playing in the background.
     
     - returns: whether or not the music is successfully playing -> from the callbacks
    */
    internal func playNextSong(completionHandler: Bool -> ()) {
        var services: [Service] = [.Soundcloud, .iTunes]
        if PlaylistHandler.spotifySessionIsValid() {
            services.append(.Spotify)
        }
        if let nextSong = SongHandler.getTopSongWithPlatformConstraints(services) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            PlaylistHandler.nowPlaying = nextSong

            playing = true
            self.registerNextSongWithServer(nextSong)

            switch(nextSong.service!){
            case .Soundcloud:
                playSoundCloud(completionHandler)
            case .Spotify:
                playSpotify(completionHandler)
            case .iTunes:
                playLocalSong(completionHandler)
            }
        } else {
            PlaylistHandler.nowPlaying = nil
            playing = false
            // register an empty song or something
            //            self.registerNextSongWithServer(nil)
            completionHandler(false)
            PlaylistHandler.stop()
        }
    }

    internal func songEnded() {
        PlaylistHandler.playNextSong({(result) in ()})
    }

    /**
     This method hails from the MPMusicPlayer delegate, it is called when the MPMusicPlayer
     changes state.
     
     When the music is stopped, we play the next song.
    */
    internal func handlePlaybackStateChanged(notification: NSNotification) {
        if (self.localPlayer.playbackState == .Stopped) {
            songEnded()
        }
    }

    /**
     Stop all music, on any platforms that are playing.
     
     - bug: SoundCloud stopping is very slow.
    */
    internal func stopCurrentSong() {
        if playing {
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                self.playing = false
                switch(PlaylistHandler.nowPlaying!.service!) {
                case .Soundcloud:
                    self.soundcloudPlayer!.pause()
                case .iTunes:
                    self.localPlayer.pause()
                case .Spotify:
                    self.spotifyPlayer.setIsPlaying(false, callback: nil)
                }
            })
        }
    }

    /**
     Called when we want to play a song from the iPhone's local music
     
     - precondition: `nowPlaying` must have `Service.iTunes`
     
     - returns: whether playing was successful
    */
    private func playLocalSong(completionHandler: Bool -> Void) {
        let song = SongHandler.getLocalSongByTitleAndAlbumTitle(PlaylistHandler.nowPlaying!.title!, albumTitle: PlaylistHandler.nowPlaying!.description!)
        let itemCollection: MPMediaItemCollection = MPMediaItemCollection(items: [song])

//        let index: Int = Int(PlaylistHandler.nowPlaying!.trackId!)!
//        let nowPlayingItem: MPMediaItem! = SongHandler.allLocalITunesOriginals![index]
//        let itemCollection: MPMediaItemCollection = MPMediaItemCollection(items: [nowPlayingItem])
        localPlayer.setQueueWithItemCollection(itemCollection)
        localPlayer.prepareToPlay()
        localPlayer.repeatMode = .None
        localPlayer.play()
        completionHandler(true)
    }

    /**
     Called when we want to play a song from SoundCloud.

     - precondition: `nowPlaying` must have `Service.SoundCloud`
     - returns: whether playing was successful
    */
    private func playSoundCloud(completionHandler: Bool -> Void) {
        let url = "https://api.soundcloud.com/tracks/" + (PlaylistHandler.nowPlaying?.trackId)! + "/stream?client_id=50ea1a6c977ecf3fb47ecaf6078c388b"
        print(url)
        let soundData = NSData(contentsOfURL: NSURL(string: url)!)
        soundcloudPlayer = try? AVAudioPlayer(data: soundData!)
        // ^ this takes a while, surprisingly.
        // maybe let's see if the SDK has changed

        if let p = soundcloudPlayer {
            p.prepareToPlay()
            p.delegate = self
            p.volume = 1.0
            p.play()
            print("Soundcloud is playing track")
            completionHandler(true)
        } else {
            print("Soundcloud player failed.")
            completionHandler(false)
        }
    }

    /**
     Called when we want to play a song from Spotify.

     - precondition: `nowPlaying` must have `Service.Spotify`
     - returns: whether playing was successful
     */
    private func playSpotify(completionHandler: Bool -> Void) {
        if !PlaylistHandler.spotifySessionIsValid() {
            print("not logged into spotify!")
            completionHandler(false)
        } else {
            spotifyPlayer.loginWithSession(PlaylistHandler.spotifySession, callback: { (error: NSError?) in
                if (error != nil) {
                    print("Logging had error:")
                    print(error)
                    completionHandler(false)
                    return
                }})
            let trackURI: NSURL = NSURL(string: ("spotify:track:"+String(PlaylistHandler.nowPlaying!.trackId!)))!
            print(trackURI)
            spotifyPlayer.playURI(trackURI, callback: {(error: NSError?) in
                if (error != nil) {
                    print("Starting playback had error")
                    print(error)
                    completionHandler(false)
                    return
                } //else {
//                    self.spotifyPlayer.setIsPlaying(true, callback: nil)
//                }
            })
        }
        completionHandler(true)
    }

    /**
     This method hails from the SPTAudioStreamingPlaybackDelegate.
     It is called when the audioStreaming changes.
     
     It plays the next song.
 
    */
    internal func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if trackMetadata == nil {
            songEnded()

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("MusicPlayer does not support NSCoding")
    }
}