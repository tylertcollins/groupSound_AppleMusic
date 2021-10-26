//
//  CreateUserResponse.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import Foundation

struct CreateUserResponse: Codable {
    let user: [UserResponse]
}

struct UserResponse: Codable {
    let username: String
    let user_display_name: String
    let email: String
}
