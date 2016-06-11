//
//  IntegratedMusicPlayer.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/16/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
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
    var appleMusicPlayer: MPMusicPlayerController

    var playing: Bool

    override init() {
        spotifyPlayer = SPTAudioStreamingController.init(clientId: SPTAuth.defaultInstance().clientID)
        appleMusicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        playing = false
        super.init()
        spotifyPlayer.playbackDelegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IntegratedMusicPlayer.handlePlaybackStateChanged(_:)), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: self.appleMusicPlayer)
        appleMusicPlayer.beginGeneratingPlaybackNotifications()
    }

    /**
     A function to toggle the playing status of the player.
     */
    func togglePlayingStatus(completionHandler: Bool -> Void) {
        if let currentSong = PlaylistHandler.nowPlaying {
            switch MusicPlatform(str: currentSong.musicPlatform!) {
            case .Soundcloud:
                if playing {
                    soundcloudPlayer?.pause()
                } else {
                    soundcloudPlayer?.play()
                }
            case .Spotify:
                spotifyPlayer.setIsPlaying(!playing,callback: nil)
            case .LocalLibrary:
                playing ? appleMusicPlayer.pause() : appleMusicPlayer.play()
            case .AppleMusic:
                playing ? appleMusicPlayer.pause() : appleMusicPlayer.play()
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
        print("soundcloud finished playing")
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
    private func registerNextSongWithServer(song: QueuedSong ) {
        // At song end, the previous song was pushed forward (PRE)


        // 1) Push forward the active status of this song
        APIHandler.updateSongActiveStatus(song.id!, activeStatus: .NowPlaying, completion: {
            (result: Bool) in
            if result {
                // good
            } else {
                // was error in server communication
            }
        })
    }

    /**
     This function gets the next song from the playlist controller, then tries to play it, calling
     the other methods in this class depending on the platform.
     
     It also tells the iPhone that music is playing in the background.
     
     - returns: whether or not the music is successfully playing -> from the callbacks
    */
    internal func playNextSong(completionHandler: Bool -> ()) {
        var musicPlatforms: Set<MusicPlatform> = Set([.Soundcloud, .LocalLibrary])
        if PlaylistHandler.spotifySessionIsValid() {
            musicPlatforms.insert(.Spotify)
        }
        if let nextSong = SongHandler.getTopSongWithPlatformConstraints(musicPlatforms) {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)

            PlaylistHandler.nowPlaying = nextSong
            playing = true
            registerNextSongWithServer(nextSong)
            switch MusicPlatform(str: nextSong.musicPlatform!) {
            case .Soundcloud:
                playSoundCloud(completionHandler)
            case .Spotify:
                playSpotify(completionHandler)
            case .LocalLibrary:
                playLocalSong(completionHandler)
            case .AppleMusic:
                playAppleMusicSong(completionHandler)
            }

        } else {
            PlaylistHandler.nowPlaying = nil
            playing = false
            completionHandler(false)
            PlaylistHandler.stop()
        }
        APIHandler.updateAPIInformation()
    }

    internal func songEnded() {
        print("songEnded() was called")
        PlaylistHandler.playNextSong({(result) in ()})
    }

    /**
     This method hails from the MPMusicPlayer delegate, it is called when the MPMusicPlayer
     changes state.
     
     When the music is stopped, we play the next song.
    */
    internal func handlePlaybackStateChanged(notification: NSNotification) {
        if (self.appleMusicPlayer.playbackState == .Stopped) {
            print("mp music player ended 'naturally' ")
            songEnded()
        }
    }

    internal func markCurrentSongAsCompleted() {
        APIHandler.updateSongActiveStatus(PlaylistHandler.nowPlaying!.id!, activeStatus: .History, completion: {
            (result: Bool) in
            if result {
                // it worked
            } else {
                // error
            }
        })
    }

    /**
     Stop all music, on any platforms that are playing.
     
     - bug: SoundCloud stopping is very slow.
    */
    internal func stopCurrentSong() {
        if playing {
            self.markCurrentSongAsCompleted()
            self.playing = false
            switch MusicPlatform(str: (PlaylistHandler.nowPlaying?.musicPlatform!)!) {
            case .Soundcloud:
                self.soundcloudPlayer!.pause()
            case .LocalLibrary:
                self.appleMusicPlayer.pause()
            case .Spotify:
                self.spotifyPlayer.setIsPlaying(false, callback: nil)
            case .AppleMusic:
                self.appleMusicPlayer.pause()
            }
        }
    }

    private func playAppleMusicSong(completionHandler: Bool -> Void) {
        if let song = PlaylistHandler.nowPlaying {
            let storeIds = [song.trackId!]
            if #available(iOS 9.3, *) {
                appleMusicPlayer.setQueueWithStoreIDs(storeIds)
                appleMusicPlayer.prepareToPlay()
                appleMusicPlayer.repeatMode = .None
                appleMusicPlayer.play()
                completionHandler(true)
            } else {
                // non-accessible
            }
        }
    }

    /**
     Called when we want to play a song from the iPhone's local music
     
     - precondition: `nowPlaying` must have `Service.iTunes`
     
     - returns: whether playing was successful
    */
    private func playLocalSong(completionHandler: Bool -> Void) {
        let song = SongHandler.getSongByArrayIndex(Int(PlaylistHandler.nowPlaying!.trackId!)!)
        let itemCollection = MPMediaItemCollection(items: [song!])
        appleMusicPlayer.setQueueWithItemCollection(itemCollection)
        appleMusicPlayer.prepareToPlay()
        appleMusicPlayer.repeatMode = .None
        appleMusicPlayer.play()
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
                }
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
            print("spotify ended and was caught")
            songEnded()

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("MusicPlayer does not support NSCoding")
    }
}