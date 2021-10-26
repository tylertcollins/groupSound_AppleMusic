//
//  GroupSoundAuthManager.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import Foundation

final class GroupSoundAuthManager {
    
    static let shared = GroupSoundAuthManager()
    
    static let clientID = ""
    
    var isSignedIn: Bool {
        return username != nil
    }
    
    public var username = UserDefaults.standard.value(forKey: "groupsoundUsername") {
        didSet {
            UserDefaults.standard.setValue(username, forKey: "groupsoundUsername")
        }
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExperationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "groupsoundUsername")
    }
}
