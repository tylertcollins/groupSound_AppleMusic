//
//  AppleAuthManager.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/20/21.
//

import Foundation
import StoreKit

class AppleAuthManager {
    
    static var shared = AppleAuthManager()
    
    var accountLinked: Bool {
        return userToken != nil
    }
    
    var storeFrontID = UserDefaults.standard.string(forKey: "AppleMusicStoreFrontID") {
        didSet {
            UserDefaults.standard.setValue(storeFrontID, forKey: "AppleMusicStoreFrontID")
        }
    }
    
    var userToken = UserDefaults.standard.string(forKey: "AppleMusicUserToken") {
        didSet {
            UserDefaults.standard.setValue(userToken, forKey: "AppleMusicUserToken")
        }
    }
    
    let developerToken = "####"
    
    public func getUserToken(completion: @escaping(_ success: Bool) -> Void) {
        SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken) { [weak self] (receivedToken, error) in
            guard error == nil, let userToken = receivedToken else {
                completion(false)
                return
            }
            
            self?.userToken = userToken
            completion(true)
        }
    }
    
    public func authorizeMusicLibrary(completion: @escaping(_ success: Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { status in
            switch status {
            case .denied, .restricted:
                // Prompt that apple music funtionality is required
                completion(false)
                break
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    public func fetchStoreFrontID(completion: @escaping(Result<String, Error>) -> Void) {
        guard let userToken = userToken else {
            completion(.failure(APIError.InvalidJSONReturned))
            return
        }
        var storeFrontID: String!
        
        let musicURL = URL(string: "https://api.music.apple.com/v1/me/storefront")!
        var musicRequest = URLRequest(url: musicURL)
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        URLSession.shared.dataTask(with: musicRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(APIError.InvalidJSONReturned))
                return
            }
            
            if let json = try? JSON(data: data!) {
                let result = (json["data"]).array!
                let id = (result[0].dictionaryValue)["id"]!
                storeFrontID = id.stringValue
                self.storeFrontID = storeFrontID
                completion(.success(storeFrontID))
            } else {
                completion(.failure(APIError.InvalidJSONReturned))
            }
        }.resume()
    }
    
}
