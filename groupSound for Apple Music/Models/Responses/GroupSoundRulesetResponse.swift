//
//  GroupSoundRulesetResponse.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/27/21.
//

import Foundation

struct GroupSoundRulesetResponse: Codable {
    let ruleset_id: String
    let skip_type: String
    let skips_required: String
    let order_type: String
    let allow_explicit: String
    let song_min_duration: String
    let song_max_duration: String
    let max_users: String
    let max_song_count: String
    let max_user_song_count: String
    let allow_repeats: String
    let max_songs_add: String
}
