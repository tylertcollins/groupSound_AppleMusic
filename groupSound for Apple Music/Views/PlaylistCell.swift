//
//  PlaylistCell.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit

class PlaylistCell: UITableViewCell {
    
    var playlist: GroupSoundPlaylistModel? {
        didSet {
            playlistNameLabel.text = playlist?.playlistName
            hostUsernameLabel.text = playlist?.hostUsername
        }
    }
    
    private let playlistView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()
    
    private let hostUsernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.italicSystemFont(ofSize: 20)
        label.textAlignment = .left
        return label
    }()
    
    private let trackCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .right
        label.text = "0"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(playlistView)
        playlistView.addSubview(playlistNameLabel)
        playlistView.addSubview(hostUsernameLabel)
        playlistView.addSubview(trackCountLabel)
        
        backgroundColor = .black
        
        let padding: CGFloat = 16
        
        playlistView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0, enableInsets: false)
        playlistNameLabel.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: padding, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        hostUsernameLabel.anchor(top: playlistNameLabel.bottomAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        trackCountLabel.anchor(top: hostUsernameLabel.bottomAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: padding, paddingBottom: 5, paddingRight: padding, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
