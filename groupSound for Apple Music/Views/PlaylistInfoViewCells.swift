//
//  PlaylistInfoViewCells.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/26/21.
//

import Foundation
import UIKit

class InviteCodeCell: UITableViewCell {
    
    let inviteCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 35)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    var inviteCode: String? {
        didSet {
            inviteCodeLabel.text = inviteCode
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        addSubview(inviteCodeLabel)
        
        selectedBackgroundView = contentView
        
        inviteCodeLabel.anchor(centerX: centerXAnchor, centerY: centerYAnchor, top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RulesetItemCell: UITableViewCell {
    
    public var rulesetItemKey: String = "" {
        didSet {
            rulesetItemKeyLabel.text = rulesetItemKey
        }
    }
    public var rulesetItemValue: String = "" {
        didSet {
            rulesetItemValueLabel.text = rulesetItemValue
        }
    }
    
    private let rulesetItemKeyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .darkGray
        return label
    }()
    
    private let rulesetItemValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 26, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        addSubview(rulesetItemKeyLabel)
        addSubview(rulesetItemValueLabel)
        
        rulesetItemKeyLabel.anchor(centerX: nil, centerY: centerYAnchor, top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: centerXAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        rulesetItemValueLabel.anchor(centerX: nil, centerY: centerYAnchor, top: topAnchor, left: centerXAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 10, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PlaylistOptionsCell: UITableViewCell {
    
    private let updatePlaylistButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.titleLabel?.textColor = .white
        button.setTitle("Update Playlist", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let deletePlaylistButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.titleLabel?.textColor = .white
        button.setTitle("Delete Playlist", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        return button
    }()
    
    public var deleteButtonHandler: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        addSubview(updatePlaylistButton)
        addSubview(deletePlaylistButton)
        
        updatePlaylistButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50, enableInsets: false)
        deletePlaylistButton.anchor(top: updatePlaylistButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 50, paddingRight: 0, width: 0, height: 50, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapDeleteButton() {
        self.deleteButtonHandler?()
    }
    
}
