//
//  PlaylistsViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    private var groupSoundPlaylistCells: [GroupSoundPlaylistModel] = []
    
    private var groupsoundPlaylists: [GroupSoundPlaylist] = []

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Playlists"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .left
        return label
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .white
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(didTapAddPlaylist), for: .touchUpInside)
        return button
    }()
    
    private var playlistTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .black
        tableview.separatorColor = .clear
        return tableview
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let indicatorview = UIActivityIndicatorView()
        indicatorview.hidesWhenStopped = true
        return indicatorview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = .black
        
        configureTableView()
        layoutSubviews()
        fetchPlaylists()
    }
    
    private func layoutSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(settingsButton)
        view.addSubview(playlistTableView)
        view.addSubview(loadingIndicator)
        
        settingsButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40, enableInsets: false)
        addButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: settingsButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40, enableInsets: false)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: addButton.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 40, enableInsets: false)
        playlistTableView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        loadingIndicator.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100, enableInsets: false)
    }
    
    private func configureTableView() {
        playlistTableView.register(PlaylistCell.self, forCellReuseIdentifier: "GroupSoundPlaylistCell")
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        playlistTableView.addSubview(refreshControl)
    }
    
    private func fetchPlaylists() {
        loadingIndicator.startAnimating()
        GroupSoundAPI.shared.fetchPlaylists { [weak self] results in
            switch results {
            case .success(let playlists):
                DispatchQueue.main.async { self?.mapPlaylistsModels(playlists) }
            case .failure(let error):
                print("Error retreiving playlists: \(error)")
            }
        }
    }
    
    private func mapPlaylistsModels(_ playlistResponse: GroupSoundPlaylistResponse) {
        groupsoundPlaylists.removeAll()
        groupSoundPlaylistCells.removeAll()
        
        groupsoundPlaylists = playlistResponse.playlists
        for playlist in playlistResponse.playlists {
            groupSoundPlaylistCells.append(GroupSoundPlaylistModel(playlistName: playlist.playlist_name, hostUsername: playlist.host_username, playlistID: playlist.playlist_id))
        }
        loadingIndicator.stopAnimating()
        self.playlistTableView.reloadData()
    }
    
    private func presentPlaylistCreationViewController() {
        let vc = PlaylistCreationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPlaylistCodeEntry() {
        let alert = UIAlertController(title: "Enter Playlist Invite Code", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Invite Code"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textfield = alert.textFields?[0], let inviteCode = textfield.text else {
                return
            }
            
            self.addPlaylistWithCode(code: inviteCode)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addPlaylistWithCode(code: String) {
        GroupSoundAPI.shared.addPlaylist(withCode: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case true:
                    self?.fetchPlaylists()
                case false:
                    // Display Error adding song message
                    print("Failure to add user to playlist")
                }
            }
        }
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAddPlaylist() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let createNewPlaylistAction = UIAlertAction(title: "Create New Playlist", style: .default) { [weak self] _ in
            self?.presentPlaylistCreationViewController()
        }
        let playlistCodeAction = UIAlertAction(title: "Enter Playlist Code", style: .default) { [weak self] _ in
            self?.presentPlaylistCodeEntry()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(createNewPlaylistAction)
        alert.addAction(playlistCodeAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didPullToRefresh() {
//        self.fetchPlaylists()
        self.refreshControl.endRefreshing()
    }
}

extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSoundPlaylistCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupSoundPlaylistCell", for: indexPath) as! PlaylistCell
        let playlist = groupSoundPlaylistCells[indexPath.row]
        cell.playlist = playlist
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NowPlayingViewController()
        vc.viewPlaylist = groupsoundPlaylists[indexPath.row]
        vc.deletePlaylistHandler = { [weak self] in
            self?.fetchPlaylists()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
