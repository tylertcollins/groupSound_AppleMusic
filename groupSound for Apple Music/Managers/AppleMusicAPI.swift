//
//  APICaller.swift
//  APICaller
//
//  Created by Tyler Collins on 7/20/21.
//

import Foundation
import StoreKit

class AppleMusicAPI {
    
    static let shared = AppleMusicAPI()
    
    func searchAppleMusic(_ searchTerm: String!, completion: @escaping(Result<[AppleMusicTrack], Error>) -> Void) {
        guard let userToken = AppleAuthManager.shared.userToken, let storeFrontID = AppleAuthManager.shared.storeFrontID else { return }
        
        var tracks = [AppleMusicTrack]()
        let sanitizedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        let musicURL = URL(string: "https://api.music.apple.com/v1/catalog/\(storeFrontID)/search?term=\(sanitizedSearchTerm)&types=songs&limit=25")!
        var musicRequest = URLRequest(url: musicURL)
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(AppleAuthManager.shared.developerToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: musicRequest) { data, response, error in
            guard error == nil else { return }
            
            if let json = try? JSON(data: data!) {
                let result = (json["results"]["songs"]["data"]).array!
                
                for track in result {
                    let attributes = track["attributes"]
                    let currentTrack = AppleMusicTrack(id: attributes["playParams"]["id"].string!, name: attributes["name"].string!, artistName: attributes["artistName"].string!, artworkURL: attributes["artwork"]["url"].string!)
                    tracks.append(currentTrack)
                }
                
                completion(.success(tracks))
            } else {
                completion(.failure(APIError.InvalidJSONReturned))
            }
        }.resume()
    }
    
    func fetchTrack(withId trackId: String, completion: @escaping(Result<AppleMusicTrack, Error>) -> Void) {
        guard let userToken = AppleAuthManager.shared.userToken, let storeFrontID = AppleAuthManager.shared.storeFrontID else { return }
        
        guard let musicURL = URL(string: "https://api.music.apple.com/v1/catalog/\(storeFrontID)/songs/\(trackId)") else { return }
        var musicRequest = URLRequest(url: musicURL)
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(AppleAuthManager.shared.developerToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: musicRequest) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let json = try? JSON(data: data) {
                let result = (json["data"])
                
                let attributes = result["attributes"]
                let currentTrack = AppleMusicTrack(id: attributes["playParams"]["id"].string!, name: attributes["name"].string!, artistName: attributes["artistName"].string!, artworkURL: attributes["artwork"]["url"].string!)
                
                completion(.success(currentTrack))
            } else {
                completion(.failure(APIError.InvalidJSONReturned))
            }
        }.resume()
    }
    
}


