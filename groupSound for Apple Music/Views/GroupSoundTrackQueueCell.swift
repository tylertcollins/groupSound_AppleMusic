//
//  GroupSoundTrackQueueCell.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit

class GroupSoundTrackQueueCell: UITableViewCell {
    
    public var trackCellModel: GroupSoundTrackQueueCellModel? {
        didSet {
            trackNameLabel.text = trackCellModel?.trackName
            trackArtistLabel.text = trackCellModel?.trackArtist
        }
    }
    
    public var cellType: TrackQueueCellType = .enqueued {
        didSet {
            layoutCell()
        }
    }
    
//    @objc public var holdGestureHandler: (() -> Void)?
    
    private let limitContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        return view
    }()
    
    private let albumImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.layer.cornerRadius = 8
        imageview.backgroundColor = .systemGreen
        return imageview
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        return label
    }()
    
    private let trackArtistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    private let skippedImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "forward.fill")
        imageview.isHidden = true
        return imageview
    }()
    
    private let holdGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 1
        return gesture
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        addSubview(limitContentView)
        limitContentView.addSubview(albumImageView)
        limitContentView.addSubview(skippedImageView)
        limitContentView.addSubview(trackNameLabel)
        limitContentView.addSubview(trackArtistLabel)
        
//        holdGesture.addTarget(self, action: #selector(getter: holdGestureHandler))
//        self.addGestureRecognizer(holdGesture)
        
        limitContentView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 1, paddingLeft: 10, paddingBottom: 1, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        albumImageView.anchor(top: limitContentView.topAnchor, left: limitContentView.leftAnchor, bottom: limitContentView.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 45, height: 0, enableInsets: false)
        skippedImageView.anchor(top: albumImageView.topAnchor, left: albumImageView.leftAnchor, bottom: albumImageView.bottomAnchor, right: albumImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        trackNameLabel.anchor(top: limitContentView.topAnchor, left: albumImageView.rightAnchor, bottom: nil, right: limitContentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        trackArtistLabel.anchor(top: trackNameLabel.bottomAnchor, left: albumImageView.rightAnchor, bottom: limitContentView.bottomAnchor, right: limitContentView.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
    }
    
    private func layoutCell() {
        var limitContentPadding: CGFloat = 0
        var limitContentViewShadow: Float = 0.0
        switch cellType {
        case .played:
            limitContentPadding = 10
            limitContentView.backgroundColor = .darkGray
            limitContentViewShadow = 0.0
            if trackCellModel?.hasBeenPlayed.bool ?? false { skippedImageView.isHidden = false }
            else { skippedImageView.isHidden = true }
        case .currentlyPlaying:
            limitContentPadding = 0
            limitContentView.backgroundColor = .white
            limitContentViewShadow = 0.5
            skippedImageView.isHidden = true
        case .enqueued:
            limitContentPadding = 10
            limitContentView.backgroundColor = .white
            limitContentViewShadow = 0.0
            skippedImageView.isHidden = true
        }
        
        removeConstraints(constraints)
        limitContentView.layer.shadowOpacity = limitContentViewShadow
        limitContentView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 1, paddingLeft: limitContentPadding, paddingBottom: 1, paddingRight: limitContentPadding, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
