//
//  PlaybackManager.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/20/21.
//

import AVFoundation
import Foundation
import MediaPlayer

/// Handles all app playback, music controls, and playlist updates
class PlaybackManager {
    
    // MARK: - Singleton Instance
    
    static var shared = PlaybackManager()
    
    // MARK: - Public Parameters
    
    /// Controls playback of music for application and used to fetch currently playing information
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    /// The playlist that the music player is currently playing
    public var currentPlaylist: GroupSoundPlaylist?
    
    /// The music track that the music player is currently playing
    public var currentTrack: GroupSoundTrack?
    
    /// The list of tracks that the music player is playing
    /// Contains all tracks, where already played tracks are flagged as played
    public var trackQueue: [GroupSoundTrack] = []
    
    /// The index of the track that is currently being played
    public var currentTrackIndex: Int?
    
    // MARK: - Private Parameters
    
    /// Indicates if the user initated pause
    private var userPaused = false
    
    /// Indicates if the host initated pause
    private var hostPaused = false
    
    /// The type of listening that the user is currently using
    private var sessionType: PlaybackOption = .privateListening
    
    // MARK: - Delegates
    
    /// The viewcontroller that will display the music players information
    public weak var delegate: PlaybackManagerViewPort? {
        didSet {
            updateViewPort()
        }
    }
    
    // MARK: - Public Functions
    
    /// Sets up the music player to update the playlist track queue
    /// and starts playing track queue from the beginning
    /// - Parameter playlist: The playlist that will be played
    public func beginPrivateListeningPlayback(forPlaylist playlist: GroupSoundPlaylist) {
        currentPlaylist = playlist
        sessionType = .privateListening
        
        musicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playbackStatusDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentTrackHasChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        updatePlaylist { [weak self] success in
            switch success {
            case true:
                self?.currentTrack = self?.trackQueue.first
                self?.currentTrackIndex = 0
                self?.musicPlayer.setQueue(with: self?.trackQueue.map { $0.song_id } ?? [] )
                self?.musicPlayer.prepareToPlay() { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    self?.musicPlayer.play()
                    self?.delegate?.didBeginPlayback()
                }
            case false:
                break
            }
        }
    }
    
    /// Waits for a socket connection to be established before syncing with the host
    /// and starting playback of the current track from the host
    /// - Parameter playlist: The playlist that will be joined and played
    public func connectJoinedSession(forPlaylist playlist: GroupSoundPlaylist) {
        guard ConnectionManager.shared.connectionEstablished else {
            ConnectionManager.shared.onConnection.append(connectJoinedSession(forPlaylist: ))
            return
        }
        
        currentPlaylist = playlist
        sessionType = .sessionListening
        
        ConnectionManager.shared.send(request: .playbackTime)
    }
    
    
    /// Waits for a socket connection to be established before starting playback
    /// - Parameter playlist: The playlist that will started and played
    public func connectStartSession(forPlaylist playlist: GroupSoundPlaylist) {
        
        guard ConnectionManager.shared.connectionEstablished else {
            ConnectionManager.shared.onConnection.append(connectStartSession(forPlaylist:))
            return
        }
        
        currentPlaylist = playlist
        sessionType = .sessionHosting
        
        startPlayback(forPlaylist: playlist, seekTime: nil)
    }
    
    
    /// Stops playback and resets PlaybackManager to cleared values
    public func endPlaybackSession() {
        musicPlayer.stop()
        currentTrack = nil
        currentTrackIndex = nil
        currentPlaylist = nil
        trackQueue = []
        userPaused = false
        delegate?.didEndPlayback()
        delegate = nil
        sessionType = .privateListening
        musicPlayer.setQueue(with: [])
    }
    
    
    /// Executes pause or play command initiated by the current user
    /// If session, user resyncs to host before playing
    public func pausePlayCommandPressed() {
        switch sessionType {
        case .privateListening:
            if musicPlayer.playbackState == .playing {
                musicPlayer.pause()
            } else {
                musicPlayer.play()
            }
            break
        case .session, .sessionListening:
            if musicPlayer.playbackState == .playing {
                musicPlayer.pause()
                userPaused = true
            } else {
                // Sync player then play
                ConnectionManager.shared.send(request: .playbackTime)
                userPaused = false
            }
            break
        case .sessionHosting:
            if musicPlayer.playbackState == .playing {
                musicPlayer.pause()
                ConnectionManager.shared.send(event: .pause)
                // Send connection update
            } else {
                musicPlayer.play()
                ConnectionManager.shared.send(event: .play)
                
                // Send connection update
            }
            break
        }
    }
    
    /// Execute pause command that was received from the websocket
    public func pauseCommandReceived() {
        hostPaused = true
        musicPlayer.pause()
    }
    
    /// Executes play command that was received from the websocket
    /// Does not execute if pause was executed by user
    public func playCommandReceived() {
        hostPaused = false
        if !self.userPaused {
            self.musicPlayer.play()
        }
    }
    
    
    /// Executes play command and sets current playback time to received time
    /// - Parameter seekTime: The time that the current track will begin playing at
    public func playCommand(atTime seekTime: TimeInterval) {
        musicPlayer.play()
        musicPlayer.currentPlaybackTime = seekTime
    }
    
    /// Executes skip command initiated by the current user
    public func skipCommandPressed() {
        switch sessionType {
        case .privateListening:
            musicPlayer.skipToNextItem()
        case .session, .sessionListening, .sessionHosting:
            // Send Connection for skip vote
            ConnectionManager.shared.send(event: .skipVoteAdded)
            break
        }
    }
    
    /// Executes skip command
    public func skipCommandReceived() {
        musicPlayer.skipToNextItem()
    }
    
    /// Fetches and updates the users playlist then assigns parameters and track queue
    /// Begins playback based on the current track
    /// - Parameters:
    ///   - playlist: The playlist that will be played
    ///   - seekTime: The time that current track will start at
    public func startPlayback(forPlaylist playlist: GroupSoundPlaylist, seekTime: TimeInterval?) {
        musicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playbackStatusDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentTrackHasChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        updatePlaylist { [weak self] success in
            switch success {
            case true:
                if self?.currentTrackIndex == nil { self?.currentTrackIndex = self?.trackQueue.firstIndex(where: { $0.song_id == playlist.current_track }) }
                if self?.currentTrackIndex == nil { self?.currentTrackIndex = 0 }
                self?.currentTrack = self?.trackQueue[(self?.currentTrackIndex)!]
                if let upcomingQueue = self?.trackQueue[(self?.currentTrackIndex)!...(self?.trackQueue.endIndex)! - 1] {
                    self?.musicPlayer.setQueue(with: upcomingQueue.map { $0.song_id } )
                    self?.musicPlayer.prepareToPlay() { error in
                        guard error == nil else {
                            print(error as Any)
                            return
                        }
                        self?.musicPlayer.play()
                        if let seekTime = seekTime {
                            self?.musicPlayer.currentPlaybackTime = seekTime
                        }
                        self?.delegate?.didBeginPlayback()
                    }
                }
            case false:
                break
            }
        }
    }
    
    public func updateTrackQueueReceived() {
        guard let playlist = currentPlaylist else { return }
        
        updatePlaylist { [weak self] success in
            switch success {
            case true:
                self?.currentTrackIndex = self?.trackQueue.firstIndex(where: { $0.song_id == playlist.current_track })
                if self?.currentTrackIndex == nil { self?.currentTrackIndex = 0 }
                self?.currentTrack = self?.trackQueue[(self?.currentTrackIndex)!]
                if self?.sessionType != .session, let upcomingQueue = self?.trackQueue[(self?.currentTrackIndex)!...(self?.trackQueue.endIndex)! - 1] {
                    self?.musicPlayer.setQueue(with: upcomingQueue.map { $0.song_id } )
                }
                self?.updateViewPortTrackQueue()
            case false:
                break
            }
        }
    }
    
    // MARK: - Private Functions
    
    /// Setup control center for lock screen music playback controls
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event in
            print(event)
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { event in
            print(event)
            return .success
        }
    }
    
    
    /// Updates playlist track queue and reassigns music player upcoming queue
    /// - Parameter completion: Function called after track queue is fetch with execution result
    private func updatePlaylist(completion: @escaping (Bool) -> Void) {
        guard let playlist = currentPlaylist else { return }
        GroupSoundAPI.shared.fetchPlaylistTrackQueue(forPlaylist: playlist.playlist_id) { [weak self] response in
            switch response {
            case .success(let model):
                self?.trackQueue = model.tracks
                self?.updateViewPortTrackQueue()
                completion(true)
            case .failure(let error):
                print("Error fetching track queue: \(error)")
                completion(true)
            }
        }
    }
    
    /// Notifies view port delegate to update track queue and ruleset
    private func updateViewPort() {
        guard let viewport = delegate else { return }
        viewport.updateTrackQueue(trackQueue: trackQueue)
        viewport.updateTrack()
    }
    
    /// Notifies view port delegate to update ruleset
    private func updateViewPortRuleset() {
        guard let _ = delegate else { return }
    }
    
    /// Notifies view port delegate to update track queue
    private func updateViewPortTrackQueue() {
        guard let viewport = delegate else { return }
        viewport.updateTrackQueue(trackQueue: trackQueue)
    }
    
    // MARK: - Obj-C Functions
    
    /// Updates current track, current track index, and notifies view port to update currently playing track
    @objc func currentTrackHasChanged() {
        currentTrackIndex = trackQueue.firstIndex(where: { $0.song_id  == musicPlayer.nowPlayingItem?.playbackStoreID })
        guard let currentTrackIndex = currentTrackIndex else { return }
        currentTrack = trackQueue[currentTrackIndex]
        
        
        if sessionType == .sessionHosting {
            let connectionOptions = ["track": currentTrack!.song_id]
            ConnectionManager.shared.send(event: .nextSong, withOptions: connectionOptions)
        }
        
        delegate?.updateTrack()
    }
    
    /// Handles playback changes to playback status
    /// Notifies view port delegate to update playback controls
    @objc func playbackStatusDidChange() {
        switch musicPlayer.playbackState {
        case .paused:
            print("Paused")
        case .playing:
            print("Playing")
        case .interrupted:
            print("Interruped")
        case .stopped:
            print("Stopped")
        default:
            print("Other")
        }
        delegate?.didChangePlaybackStatus(status: musicPlayer.playbackState)
    }
    
}

// MARK: - PlaybackManagerViewPort Protocol

protocol PlaybackManagerViewPort: AnyObject {
    func didChangePlaybackStatus(status: MPMusicPlaybackState)
    func updateTrack()
    func updateTrackQueue(trackQueue: [GroupSoundTrack])
    func updateRuleset()
    func didBeginPlayback()
    func didEndPlayback()
}
