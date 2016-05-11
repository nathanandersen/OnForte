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

    // returns the new playing status
    /**
     A function to toggle the playing status of the player.
     */
    func togglePlayingStatus() -> Bool {
        if let currentSong = nowPlaying {
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
            // set paused button to target
        } else {
            playing = playNextSong()
        }
        return playing

    }

    /**
     This method hails from the AVAudioPlayerDelegate protocol. It is called when
     the AVAudioPlayer finished playing a song.
     
     Inside, we simply play the next song for autoplay.
     
     - parameters:
        - player: The AVAudioPlayer
        - flag: A boolean noting whether or not the player finished successfully
 
    */
    internal func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
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
    internal func playNextSong() -> Bool {
        if let nextSong = playlistController.getNextSong() {
            // set backgrounding
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
            print(nextSong)
            nowPlaying = nextSong

            playing = true
            control.displaySong()

            self.registerNextSongWithServer(nextSong)
            switch(nowPlaying!.service!){
            case .Soundcloud:
                return playSoundCloud()
            case .Spotify:
                return playSpotify()
            case .iTunes:
                return playLocalSong()
            }
        } else {
            nowPlaying = nil
            return false
        }
    }

    /**
     This method hails from the MPMusicPlayer delegate, it is called when the MPMusicPlayer
     changes state.
     
     When the music is stopped, we play the next song.
    */
    internal func handlePlaybackStateChanged(notification: NSNotification) {
        if (self.localPlayer.playbackState == .Stopped) {
            self.playNextSong()
        }
    }

    /**
     Stop all music, on any platforms that are playing.
     
     - bug: SoundCloud stopping is very slow.
    */
    internal func stop() {
        spotifyPlayer.setIsPlaying(false,callback: nil)
//        print("1")
        soundcloudPlayer?.stop()
//        print("2")
        localPlayer.stop()
        // ^ this line takes a long time
        print("3")
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("AVAudioSession is no longer active")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        print("4")
    }

    /**
     Called when we want to play a song from the iPhone's local music
     
     - precondition: `nowPlaying` must have `Service.iTunes`
     
     - returns: whether playing was successful
    */
    private func playLocalSong() -> Bool {
        let index: Int = Int(nowPlaying!.trackId!)!
        let nowPlayingItem: MPMediaItem! = SongHandler.allLocalITunesOriginals![index]
        let itemCollection: MPMediaItemCollection = MPMediaItemCollection(items: [nowPlayingItem])
        localPlayer.setQueueWithItemCollection(itemCollection)
        localPlayer.prepareToPlay()
        localPlayer.repeatMode = .None
        localPlayer.play()
        return true
    }

    /**
     Called when we want to play a song from SoundCloud.

     - precondition: `nowPlaying` must have `Service.SoundCloud`
     - returns: whether playing was successful
    */
    private func playSoundCloud() -> Bool {
        let url = "https://api.soundcloud.com/tracks/" + (nowPlaying?.trackId)! + "/stream?client_id=50ea1a6c977ecf3fb47ecaf6078c388b"
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
            return true
        } else {
            print("Soundcloud player failed.")
            return false
        }
    }
    /**
     Called when we want to play a song from Spotify.

     - precondition: `nowPlaying` must have `Service.Spotify`
     - returns: whether playing was successful
     */
    private func playSpotify() -> Bool {
        if spotifySession == nil || !spotifySession!.isValid() {
            print("not logged into spotify!")
            return false
        } else {
            spotifyPlayer.loginWithSession(spotifySession, callback: { (error: NSError?) in
                if (error != nil) {
                    print("Logging had error:")
                    print(error)
                    return
                }})
            let trackURI: NSURL = NSURL(string: ("spotify:track:"+String(nowPlaying!.trackId!)))!
            print(trackURI)
            spotifyPlayer.playURI(trackURI, callback: {(error: NSError?) in
                if (error != nil) {
                    print("Starting playback had error")
                    print(error)
                    return
                }
            })
        }
        return true
    }

    /**
     This method hails from the SPTAudioStreamingPlaybackDelegate.
     It is called when the audioStreaming changes.
     
     It plays the next song.
 
    */
    internal func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if trackMetadata == nil {
            playNextSong()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("MusicPlayer does not support NSCoding")
    }
}