//
//  PlaylistResponse.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import Foundation

struct GroupSoundPlaylistResponse: Codable {
    let playlists: [GroupSoundPlaylist]
}

struct GroupSoundPlaylist: Codable {
    let host_username: String
    let invite_code: String
    let playlist_id: String
    let playlist_name: String
    let ruleset_id: String
    let skip_count: String
    let last_updated: String
    let playback_status: String
    let current_track: String?
}
