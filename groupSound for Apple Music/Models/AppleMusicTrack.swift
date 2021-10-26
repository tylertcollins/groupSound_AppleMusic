//
//  Track.swift
//  Track
//
//  Created by Tyler Collins on 7/20/21.
//

import Foundation

struct GroupSoundTrack: Codable {
    let song_id: String
    let contributor_username: String
    let song_title: String
    let song_artist: String
    let song_duration: String
    let service_provider: String
    let date_added: String
//    let skipped: String
    let has_been_played: String
}

struct AppleMusicTrack {
    var id: String
    var name: String
    var artistName: String
    var artworkURL: String
}
