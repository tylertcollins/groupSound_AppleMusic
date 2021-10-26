//
//  Enums.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/20/21.
//

import Foundation

enum APIError: Error {
    case UserTokenNotCreated
    case InvalidJSONReturned
    case FailedURLResponse
}

enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
}

enum PlaybackOption: String {
    case privateListening
    case session
    case sessionListening
    case sessionHosting
}

enum PlaybackStatus: String {
    case paused
    case playing
    case sessionEnd
    case nextTrack
}

enum PlaybackEvent: String {
    case trackStart
    case nextTrackBegan
}

enum TrackQueueCellType: String {
    case played
    case currentlyPlaying
    case enqueued
}

enum SocketEvent: String {
    case pause
    case play
    case endSession
    case leaveSession
    case skip
    case skipVoteAdded
    case skipVoteRemoved
    case like
    case rulesetUpdate
    case songQueueUpdate
    case nextSong
    case pauseSuggest
    case inviteCodeUpdate
    case connected
    case joinedSession
    case logUpdate
}

enum SocketRequest: String {
    case playbackTime
}

enum SocketResponse: String {
    case playbackTimeResponse
}
