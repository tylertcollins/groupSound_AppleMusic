//
//  GroupSoundAPI.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import Foundation

final class GroupSoundAPI {
    
    // MARK: - Singleton Instance
    
    static let shared = GroupSoundAPI()
    
    // MARK: - Private Parameters
    
//    let baseURL = "http://localhost:8080/api"
    let baseURL = "###"
    
    // MARK: - Public Functions
    
    public func authorizeUser(withUsername username: String, withPassword password: String, completion: @escaping (Result<UserProfileResponse, Error>) -> Void) {
        
        let requestBody: [String: Any] = ["username": username, "password": password]
        let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        let url = URL(string: baseURL + "/user/loginUser.php")!
        
        createRequest(with: url, type: .POST, body: requestBodyData) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedURLResponse))
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                    GroupSoundAuthManager.shared.username = username
                    completion(.success(results))
                } catch {
                    completion(.failure(APIError.InvalidJSONReturned))
                }
            }.resume()
        }
    }
    
    public func emailAvailable(_ email: String, completion: @escaping(Bool) -> Void) {
        let url = URL(string: baseURL + "/user/emailAvailable.php/?email=\(email)")
        
        createRequest(with: url, type: .GET, body: nil) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                completion(response.statusCode == 200)
            }.resume()
        }
    }
    
    public func usernameAvailable(_ username: String, completion: @escaping(Bool) -> Void) {
        let url = URL(string: baseURL + "/user/usernameAvailable.php/?username=\(username)")
        
        createRequest(with: url, type: .GET, body: nil) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                completion(response.statusCode == 200)
            }.resume()
        }
    }
    
    public func createUser(withEmail email: String, withUsername username: String, withPassword password: String, completion: @escaping (Bool) -> Void) {
        
        let requestBody: [String: Any] = ["email": email, "username": username, "user_display_name": username, "password": password]
        let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        let url = URL(string: baseURL + "/user/createUser.php")!
        
        createRequest(with: url, type: .POST, body: requestBodyData) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                completion(response.statusCode == 201)
            }.resume()
        }
    }
    
    public func createPlaylist(withRuleset body: [String:Any], completion: @escaping (Bool) -> Void) {
        let requestBodyData = try? JSONSerialization.data(withJSONObject: body, options: [])
        let url = URL(string: baseURL + "/playlist/createPlaylistWithRuleset.php")!
        
        createRequest(with: url, type: .POST, body: requestBodyData) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                completion(response.statusCode == 201)
            }.resume()
        }
    }
    
    public func addPlaylist(withCode code: String, completion: @escaping (Bool) -> Void) {
        guard let username = GroupSoundAuthManager.shared.username else {
            completion(false)
            return
        }
        let url = URL(string: baseURL + "/user/addUserToPlaylist.php?username=\(username)&invite_code=\(code)")!
        
        createRequest(with: url, type: .POST, body: nil) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                completion(response.statusCode == 200)
            }.resume()
        }
    }
    
    public func fetchPlaylists(completion: @escaping (Result<GroupSoundPlaylistResponse, Error>) -> Void) {
        guard let username = GroupSoundAuthManager.shared.username else { return }
        let url = URL(string: baseURL + "/playlist/getPlaylists.php/?username=\(username)")!
        
        createRequest(with: url, type: .GET, body: nil) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedURLResponse))
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode(GroupSoundPlaylistResponse.self, from: data)
                    completion(.success(results))
                } catch {
                    completion(.failure(APIError.InvalidJSONReturned))
                }
            }.resume()
        }
    }
    
    public func fetchPlaylistTrackQueue(forPlaylist playlistID: String, completion: @escaping (Result<GroupSoundTrackQueueResponse, Error>) -> Void) {
        let url = URL(string: baseURL + "/playlist/getTrackQueue.php/?playlist_id=\(playlistID)")!
        
        createRequest(with: url, type: .GET, body: nil) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedURLResponse))
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode(GroupSoundTrackQueueResponse.self, from: data)
                    completion(.success(results))
                } catch {
                    completion(.failure(APIError.InvalidJSONReturned))
                }
            }.resume()
        }
    }
    
    public func fetchPlaylistRuleset(forRuleset rulesetID: String, completion: @escaping (Result<GroupSoundRulesetResponse, Error>) -> Void) {
        let url = URL(string: baseURL + "/ruleset/getRuleset.php/?ruleset_id=\(rulesetID)")!
        
        createRequest(with: url, type: .GET, body: nil) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedURLResponse))
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode(GroupSoundRulesetResponse.self, from: data)
                    completion(.success(results))
                } catch {
                    completion(.failure(APIError.InvalidJSONReturned))
                }
            }.resume()
        }
    }
    
    public func addTrackToPlaylist(requestBody: [String: Any], completion: @escaping (Bool) -> Void) {
        let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        let url = URL(string: baseURL + "/playlist/addSongToPlaylist.php")!
        
        createRequest(with: url, type: .POST, body: requestBodyData) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                if response.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }.resume()
        }
    }
    
    public func removeTrackFromPlaylist(requestBody: [String: Any], completion: @escaping (Bool) -> Void) {
        let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        let url = URL(string: baseURL + "/playlist/removeTrack.php")!
        
        createRequest(with: url, type: .DELETE, body: requestBodyData) { baseRequest in
            
            URLSession.shared.dataTask(with: baseRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                completion(response.statusCode == 202)
            }.resume()
        }
    }
    
    public func deletePlaylist(withID playlistID: String, completion: @escaping (Bool) -> Void) {
        let requestBody = ["playlist_id": playlistID]
        let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        let url = URL(string: baseURL + "/playlist/deletePlaylist.php")!
        
        createRequest(with: url, type: .DELETE, body: requestBodyData) { baseURL in
            URLSession.shared.dataTask(with: baseURL) { _, response, error in
                guard let response = response as? HTTPURLResponse, error == nil else {
                    completion(false)
                    return
                }
                
                if response.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }.resume()
        }
    }
    
    // MARK: - Base Request
    
    private func createRequest(with url: URL?, type: HTTPMethod, body: Data?, completion: @escaping (URLRequest) -> Void) {
        guard let apiURL = url else {
            return
        }
        var request = URLRequest(url: apiURL)
        // Manage Authorization ->
        if let httpBody = body {
            request.httpBody = httpBody
        }
        request.httpMethod = type.rawValue
        request.timeoutInterval = 1000
        completion(request)
    }
}
