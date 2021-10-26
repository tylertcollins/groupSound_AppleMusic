//
//  ConnectionManager.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 8/3/21.
//

import Foundation

final class ConnectionManager: NSObject {
    
    // MARK: - Singleton Instance
    
    static let shared = ConnectionManager()
    
    // MARK: - Public Parameters
    
    /// Indicates an active socket connection
    public var connectionEstablished = false {
        didSet { executeConnectionQueue() }
    }
    
    /// Call queue when a connection is established
    /// Add socket events to be called when connection is made
    public var onConnection: [(GroupSoundPlaylist) -> Void] = []
    
    /// Playlist that connection is exchanging events for
    public var playlist: GroupSoundPlaylist?
    
    /// Dedicated view to handle sending connection updates to
    public var viewPort: ConnectionManagerViewPort? {
        didSet {
            viewPort?.reloadStatusLog(withStatus: statusLog)
        }
    }
    
    // MARK: - Private Parameters
    
    // URL for websocket endpoint
//    private let baseURL = URL(string: "ws://localhost:3308")!
    private let baseURL = URL(string: "ws://groupsoundws.tunnelto.dev")!
    
    /// Indicates if a sync request has been issued and response has not been received yet
    private var syncRequest = false
    
    /// The current websocket connection task handling sending and receiving
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// Stores all playlist updates sent over connection
    private var statusLog: [String] = [] {
        didSet {
            guard let newStatus = statusLog.last else { return }
            viewPort?.updateStatusLog(withStatus: newStatus)
        }
    }
    
    // MARK: - Public Functions
    
    /// Ends connection with websocket
    public func closeConnection() {
        let reason = "Closing connection".data(using: .utf8)
        webSocketTask?.cancel(with: .goingAway, reason: reason)
    }
    
    /// Creates and connects to websocket using baseURL and creates
    /// connection for the current playlist
    /// - Parameter playlist: The playlist that the websocket is exchanging events for
    public func createConnection(toPlaylist playlist: GroupSoundPlaylist) {
        closeConnection()
        webSocketTask = nil
        self.playlist = playlist
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: baseURL)
        webSocketTask?.resume()
    }
    
    
    /// Sends a socket request to all other active playlist listeners
    /// - Parameter request: The request that is being sent
    public func send(request: SocketRequest) {
        let connectionJSON = ["type": "request", "request": request.rawValue]
        let JSONdata = try? JSONSerialization.data(withJSONObject: connectionJSON, options: [])
        
        self.webSocketTask?.send(.data(JSONdata!), completionHandler: { error in
            guard error == nil else {
                print("Error sending request: \(request.rawValue) - with error: \(error?.localizedDescription ?? "error")")
                return
            }
            self.syncRequest = true
            print("\(request.rawValue) sent")
        })
    }
    
    
    /// Sends a socket event to all other active playlist listeners
    /// - Parameter event: The event that is being sent
    public func send(event: SocketEvent, withOptions: [String: String]? = nil) {
        var connectionJSON: [String: Any] = ["type": "event", "event": event.rawValue]
        if let options = withOptions { connectionJSON["options"] = options }
        let JSONdata = try? JSONSerialization.data(withJSONObject: connectionJSON, options: [])
        
        self.webSocketTask?.send(.data(JSONdata!), completionHandler: { error in
            guard error == nil else {
                print("Error sending event: \(event.rawValue) - with error: \(error?.localizedDescription ?? "error")")
                return
            }
            print("\(event.rawValue) sent")
        })
    }
    
    
    public func sendTestMesssage() {
        let connectionJSON = ["type":"message", "message": "This is a test"]
        let JSONdata = try? JSONSerialization.data(withJSONObject: connectionJSON, options: [])
        
        self.webSocketTask?.send(.data(JSONdata!), completionHandler: { error in
            guard error == nil else {
                print("Error sending Test Message - with error: \(error?.localizedDescription ?? "error")")
                return
            }
            print("Test Message sent")
        })
    }
    
    
    // MARK: - Private Functions
    
    /// Sends a establish connection request to the websocket and track
    private func connectPlaylist() {
        guard let playlist = playlist, let user = GroupSoundAuthManager.shared.username as? String else { return }
        let session = playlist.host_username == user ? "start" : "join"
        do {
            let connectionJSON = ["type":"playlist_id", "playlist_id": playlist.playlist_id, "session": session, "username": user]
            let JSONdata = try JSONSerialization.data(withJSONObject: connectionJSON, options: [])
            
            self.webSocketTask?.send(.data(JSONdata)) { error in
                if let error = error {
                    print("Error sending playlistId \(error)")
                    return
                }
                print("PlaylistId sent")
            }
        } catch {
            print("Error encoding JSON")
        }
    }
    
    
    /// Goes through onConnection queue and executes each command
    private func executeConnectionQueue() {
        guard let playlist = playlist, connectionEstablished else { return }
        self.onConnection.forEach( { $0(playlist) } )
        self.onConnection.removeAll()
    }
    
    
    /// Decodes data and performs received action
    /// - Parameter data: The data received from the connection
    private func handleData(data: Data) {
        
    }
    
    /// Determines the event that was received and excutes command
    /// - Parameter event: The event received from the websocket
    private func handleEvent(packet: JSON) {
        guard let packetEvent = packet["event"].string,
              let event = SocketEvent(rawValue: packetEvent),
              let sender = packet["sender"].string
        else { return }
        
        switch event {
        case .play:
            PlaybackManager.shared.playCommandReceived()
            break
        case .pause:
            PlaybackManager.shared.pauseCommandReceived()
            break
        case .endSession:
            closeConnection()
            PlaybackManager.shared.endPlaybackSession()
            break
        case .leaveSession:
            break
        case .skip:
            PlaybackManager.shared.skipCommandReceived()
        case .skipVoteAdded:
            break
        case .skipVoteRemoved:
            break
        case .like:
            break
        case .rulesetUpdate:
            break
        case .songQueueUpdate:
            PlaybackManager.shared.updateTrackQueueReceived()
            break
        case .nextSong:
            break
        case .pauseSuggest:
            break
        case .inviteCodeUpdate:
            break
        case .connected:
            connectionEstablished = true
            print("Established connection with socket")
            return
        case .joinedSession:
            break
        case .logUpdate:
            guard let logEvent = packet["logEvent"].string,
                  let event = SocketEvent(rawValue: logEvent)
            else { return }
            updateLog(forEvent: event, from: sender)
            break
        }
    }
    
    
    /// Adds event received from socket to log
    /// - Parameters:
    ///   - event: Event that has occured from socket
    ///   - sender: User that executed event
    private func updateLog(forEvent event: SocketEvent, from sender: String) {
        switch event {
        case .pause:
            statusLog.append("\(sender) paused the session \n")
        case .play:
            statusLog.append("\(sender) started playing \n")
        case .endSession:
            statusLog.append("\(sender) ended the session \n")
        case .leaveSession:
            statusLog.append("\(sender) left the session \n")
        case .skip:
            statusLog.append("\(sender) skipped the track \n")
        case .skipVoteAdded:
            statusLog.append("\(sender) voted to skip \n")
        case .skipVoteRemoved:
            statusLog.append("\(sender) removed their skip vote \n")
        case .like:
            statusLog.append("\(sender) liked this track \n")
        case .rulesetUpdate:
            statusLog.append("\(sender) updated the playlists rules \n")
        case .songQueueUpdate:
            statusLog.append("\(sender) added a track \n")
        case .nextSong:
            break
        case .pauseSuggest:
            break
        case .inviteCodeUpdate:
            break
        case .connected:
            break
        case .joinedSession:
            statusLog.append("\(sender) joined the session \n")
        case .logUpdate:
            break
        }
    }
    
    /// Handles response from websocket
    /// - Parameter response: Received response
    private func handleResponse(packet: JSON) {
        guard let packetResponse = packet["response"].string,
              let response = SocketResponse(rawValue: packetResponse)
        else { return }
        
        switch response {
        case .playbackTimeResponse:
            guard let time = packet["time"].string,
                  let timestamp = packet["timestamp"].string,
                  let playlist = playlist,
                  syncRequest
            else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss Z"
            let startDate = dateFormatter.date(from: timestamp)
            print("Time since response: \((startDate?.timeIntervalSince(Date()))!)")
            
            let seekTime = Date().timeIntervalSince(startDate ?? Date()) + TimeInterval(time)!
            print("Start time: \(seekTime)")
            
            let testtime = Date().timeIntervalSince(startDate ?? Date()) + TimeInterval(time)!
            print("Test time: \(testtime)")
            
            if PlaybackManager.shared.currentTrack != nil {
                PlaybackManager.shared.playCommand(atTime: seekTime)
            } else {
                PlaybackManager.shared.startPlayback(forPlaylist: playlist, seekTime: seekTime)
            }
            
            self.syncRequest = false
            
        }
    }
    
    /// Determines request received and determines response
    /// - Parameter request: The request received from the websocket
    private func handleRequest(packet: JSON) {
        guard let packetRequest = packet["request"].string,
              let request = SocketRequest(rawValue: packetRequest),
              let sender = packet["sender"].int
        else { return }
        
        switch request {
        case .playbackTime:
            guard let playlist = playlist,
                  let user = GroupSoundAuthManager.shared.username as? String,
                  playlist.host_username == user
            else { return }
            
            let connectionJSON = ["type": "response", "response": SocketResponse.playbackTimeResponse.rawValue, "time": String(PlaybackManager.shared.musicPlayer.currentPlaybackTime), "timestamp": Date().description, "requestFor": String(sender)] as [String : Any]
            let JSONdata = try? JSONSerialization.data(withJSONObject: connectionJSON, options: [])
            
            self.webSocketTask?.send(.data(JSONdata!), completionHandler: { error in
                guard error == nil else {
                    print("Error sending response with error: \(error?.localizedDescription ?? "error")")
                    return
                }
                print("Response sent")
            })
        }
    }
    
    /// Checks if something has been sent by the websocket
    /// Constantly runs
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            
            switch result {
            case .success(let receivedSocketPacket):
                
                switch receivedSocketPacket {
                case .string(let packetMessage):
                    
                    let packetJSON = JSON(parseJSON: packetMessage)
                    switch packetJSON["type"].string {
                    case "event":
                        self?.handleEvent(packet: packetJSON)
                    case "response":
                        self?.handleResponse(packet: packetJSON)
                    case "request":
                        self?.handleRequest(packet: packetJSON)
                    default:
                        print("Unknown packet type received")
                    }
                    
                case .data( _):
                    print("Data socket packet received")
                @unknown default:
                    print("Unknown socket packet received")
                }

            case .failure(let error):
                print("Error receiving message: \(error)")
                return
            }
            self?.receive()
        }
    }
    
    /// Sends ping and waits for pong response every 5 seconds to determine if connection is active
    private func testConnection() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("Error sending PING: \(error)")
                return
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.testConnection()
            }
        }
    }
    
}

// MARK: - Extension: URLSessionWebSocketDelegate

extension ConnectionManager: URLSessionWebSocketDelegate {
    
    
    /// Called when a connection has been established with the websocket
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket Connected")
        testConnection()
        receive()
        connectPlaylist()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket Disconnected")
        connectionEstablished = false
    }
    
}

protocol ConnectionManagerViewPort: AnyObject {
    func updateStatusLog(withStatus: String)
    func reloadStatusLog(withStatus: [String])
}
