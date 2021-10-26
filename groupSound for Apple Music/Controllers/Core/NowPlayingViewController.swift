//
//  NowPlayingViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit
import MediaPlayer

class NowPlayingViewController: UIViewController {
    
    // MARK: - Public Parameters
    
    public var viewPlaylist: GroupSoundPlaylist? {
        didSet {
            presentView()
        }
    }
    
    public var deletePlaylistHandler: (() -> Void)?
    
    // MARK: - Private Parameters
    
    private var trackQueue: [GroupSoundTrack] = []
    
    private var trackQueueCells: [GroupSoundTrackQueueCellModel] = []
    
    private var playbackManagerView: Bool = false
    
    private var connectionManagerView: Bool = false
    
    // MARK: - View UIObjects
    
    private let sceneScrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.isPagingEnabled = true
        scrollview.alwaysBounceVertical = false
        scrollview.alwaysBounceHorizontal = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.clipsToBounds = false
        scrollview.canCancelContentTouches = false
        return scrollview
    }()
    
    private let backgroundGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.systemBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.shouldRasterize = true
        return gradientLayer
    }()
    
    private let backgroundBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let effectview = UIVisualEffectView(effect: blur)
        return effectview
    }()
    
    private let connectionActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Currently Playing UIObjects
    
    private let currentlyPlayingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        button.tintColor = .white
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(returnToPreviousView), for: .touchUpInside)
        return button
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Playlist Name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .right
        return label
    }()
    
    private let currentlyPlayingSongNameLabel: UILabel = {
        let label = UILabel()
        label.text = "No Track Playing"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private let currentlyPlayingArtistAlbumLabel: UILabel = {
        let label = UILabel()
        label.text = " - "
        label.textColor = .white
        label.font = .systemFont(ofSize: 22)
        label.textAlignment = .left
        return label
    }()
    
    private let contributorAvatarImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "person.crop.circle.fill")
        imageview.tintColor = .white
        return imageview
    }()
    
    private let contributorNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Contributor Display Name"
        label.textColor = .white
        label.font = .italicSystemFont(ofSize: 22)
        label.textAlignment = .left
        return label
    }()
    
    private let currentlyPlayingAlbumImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.backgroundColor = .gray
        imageview.layer.cornerRadius = 20
        imageview.clipsToBounds = true
        return imageview
    }()
    
    private let playlistUpdateLog: UITextView = {
        let textview = UITextView()
        textview.backgroundColor = .clear
        textview.isEditable = false
        textview.textColor = .white
        textview.font = .systemFont(ofSize: 22)
        textview.textAlignment = .left
        return textview
    }()
    
    private let trackProgressView: UIProgressView = {
        let progressview = UIProgressView()
        progressview.progressTintColor = .white
        progressview.backgroundColor = .gray
        progressview.progress = 0.0
        return progressview
    }()
    
    private let trackProgressLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
    
    private let trackProgressRightLabel: UILabel = {
        let label = UILabel()
        label.text = "-0:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    private let currentlyPlayingGoRightImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "chevron.right")
        imageview.tintColor = .white
        imageview.contentMode = .scaleToFill
        return imageview
    }()
    
    private let currentlyPlayingGoLeftImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "chevron.left")
        imageview.tintColor = .white
        imageview.contentMode = .scaleToFill
        return imageview
    }()
    
    // MARK: - Playback Controls
    
    private let playbackStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .center
        stackview.distribution = .equalCentering
        stackview.axis = .horizontal
        return stackview
    }()
    
    private let playbackOptionsHorizontalStack: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .equalCentering
        stackview.alignment = .center
        stackview.spacing = 30
        return stackview
    }()
    
    private let currentlyPlayingAddTrackButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapAddTrackButton), for: .touchUpInside)
        return button
    }()
    
    private let pausePlayButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapPausePlayButton), for: .touchUpInside)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "skip.circle.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Session Options
    
    private let sessionsStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .equalCentering
        stackview.axis = .vertical
        return stackview
    }()
    
    private let sessionOptionsVerticalStack: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .fill
        stackview.axis = .vertical
        stackview.distribution = .equalCentering
        stackview.spacing = 10
        return stackview
    }()
    
    private let sessionOptionsHorizontalStack: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .fill
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        stackview.spacing = 5
        return stackview
    }()
    
    private let joinSessionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.end.alt.fill"), for: .normal)
        button.tintColor = .white
        button.setTitle("Join Session", for: .normal)
        button.addTarget(self, action: #selector(didTapJoinSessionButton), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "004080")
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let joinAndListenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.3.fill"), for: .normal)
        button.tintColor = .white
        button.setTitle("Join and Listen", for: .normal)
        button.addTarget(self, action: #selector(didTapJoinAndListenButton), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "004080")
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let listenPrivatelyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "headphones"), for: .normal)
        button.tintColor = .white
        button.setTitle("Listen Privately", for: .normal)
        button.addTarget(self, action: #selector(didTapListenPrivately), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "004080")
        button.layer.cornerRadius = 25
        return button
    }()
    
    // MARK: - Track Queue UIObjects
    
    private let trackQueueTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track Queue"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .left
        return label
    }()
    
    private let trackQueueView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let trackQueueGoRightImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "chevron.right")
        imageview.tintColor = .white
        imageview.contentMode = .scaleToFill
        return imageview
    }()
    
    private let queueTableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    private let trackQueueAddTrackButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "004080")
        button.setTitle("Add Track", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(didTapAddTrackButton), for: .touchUpInside)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let trackQueueRefreshButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        button.tintColor = UIColor(hex: "004080")
        button.addTarget(self, action: #selector(didTapRefreshTableViewButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Playlist Info View UIObjects
    
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .right
        return label
    }()
    
    private let playlistInfoView: PlaylistInfoView = {
        let view = PlaylistInfoView()
        return view
    }()
    
    private let playlistInfoGoLeftImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "chevron.left")
        imageview.tintColor = .white
        imageview.contentMode = .scaleToFill
        return imageview
    }()

    // MARK: - Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if sceneScrollView.contentSize.height != view.safeAreaLayoutGuide.layoutFrame.height {
            sceneScrollView.contentSize = CGSize(width: view.frame.width * 3, height: view.safeAreaLayoutGuide.layoutFrame.height)
        }
    }
    
    // MARK: - Layout Functions
    
    private func presentView() {
        guard let playlist = viewPlaylist else { return }
        if let playbackPlaylist = PlaybackManager.shared.currentPlaylist {
            playbackManagerView = playlist.playlist_id == playbackPlaylist.playlist_id
            if playbackManagerView {
                PlaybackManager.shared.delegate = self
            }
        }
        
        if let connectionPlaylist = ConnectionManager.shared.playlist {
            connectionManagerView = playlist.playlist_id == connectionPlaylist.playlist_id
            if connectionManagerView {
                ConnectionManager.shared.viewPort = self
                return
            }
        }
        
        updateSessionOptions()
        updatePlaylistData()
        updatePlaylistRuleset()
    }
    
    private func layoutSubviews() {
        backgroundGradient.frame = view.bounds
        view.layer.addSublayer(backgroundGradient)
        
        view.addSubview(backgroundBlurView)
        backgroundBlurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        view.addSubview(sceneScrollView)
        sceneScrollView.addSubview(trackQueueView)
        sceneScrollView.addSubview(currentlyPlayingView)
        sceneScrollView.addSubview(playlistInfoView)
        
        sceneScrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        sceneScrollView.contentSize = CGSize(width: view.frame.width * 3, height: view.safeAreaLayoutGuide.layoutFrame.height)
        sceneScrollView.delegate = self
        
        trackQueueView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: sceneScrollView.contentSize.height)
        currentlyPlayingView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: sceneScrollView.contentSize.height)
        playlistInfoView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: sceneScrollView.contentSize.height)
        
        sceneScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: false)
        
        layoutTrackQueueView()
        layoutCurrentlyPlayingView()
        configureInfoView()
    }
    
    private func layoutTrackQueueView() {
        trackQueueView.addSubview(trackQueueTitleLabel)
        trackQueueView.addSubview(trackQueueGoRightImageView)
        trackQueueView.addSubview(trackQueueRefreshButton)
        trackQueueView.addSubview(trackQueueAddTrackButton)
        trackQueueView.addSubview(queueTableView)
        
        trackQueueTitleLabel.anchor(top: trackQueueView.safeAreaLayoutGuide.topAnchor, left: trackQueueView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: trackQueueView.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 40, enableInsets: false)
        trackQueueRefreshButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: trackQueueView.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: 50, height: 50, enableInsets: false)
        trackQueueAddTrackButton.anchor(top: nil, left: trackQueueView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: trackQueueRefreshButton.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 50, enableInsets: false)
        queueTableView.anchor(top: trackQueueTitleLabel.bottomAnchor, left: trackQueueView.safeAreaLayoutGuide.leftAnchor, bottom: trackQueueAddTrackButton.topAnchor, right: trackQueueView.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 10, paddingRight: 15, width: 0, height: 0, enableInsets: false)
        trackQueueGoRightImageView.anchor(centerX: nil, centerY: view.centerYAnchor, top: nil, left: nil, bottom: nil, right: trackQueueView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 15, height: 30, enableInsets: false)
        
        queueTableView.register(GroupSoundTrackQueueCell.self, forCellReuseIdentifier: "GroupSoundTrackQueueCell")
        queueTableView.delegate = self
        queueTableView.dataSource = self
        queueTableView.backgroundColor = .clear
    }
    
    private func layoutCurrentlyPlayingView() {
        currentlyPlayingView.addSubview(backButton)
        currentlyPlayingView.addSubview(playlistNameLabel)
        currentlyPlayingView.addSubview(currentlyPlayingAlbumImageView)
        currentlyPlayingView.addSubview(playlistUpdateLog)
        currentlyPlayingView.addSubview(contributorAvatarImageView)
        currentlyPlayingView.addSubview(contributorNameLabel)
        currentlyPlayingView.addSubview(currentlyPlayingArtistAlbumLabel)
        currentlyPlayingView.addSubview(currentlyPlayingSongNameLabel)
        currentlyPlayingView.addSubview(trackProgressView)
        currentlyPlayingView.addSubview(trackProgressLeftLabel)
        currentlyPlayingView.addSubview(trackProgressRightLabel)
        currentlyPlayingView.addSubview(currentlyPlayingGoLeftImageView)
        currentlyPlayingView.addSubview(currentlyPlayingGoRightImageView)
        
        backButton.anchor(top: currentlyPlayingView.topAnchor, left: currentlyPlayingView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 40, height: 40, enableInsets: false)
        playlistNameLabel.anchor(top: currentlyPlayingView.topAnchor, left: backButton.rightAnchor, bottom: nil, right: currentlyPlayingView.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        currentlyPlayingAlbumImageView.anchor(centerX: currentlyPlayingView.centerXAnchor, centerY: view.centerYAnchor, top: nil, left: currentlyPlayingView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: currentlyPlayingView.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: currentlyPlayingView.frame.width - 50, enableInsets: false)
        playlistUpdateLog.anchor(top: currentlyPlayingAlbumImageView.topAnchor, left: currentlyPlayingAlbumImageView.leftAnchor, bottom: currentlyPlayingAlbumImageView.bottomAnchor, right: currentlyPlayingAlbumImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        contributorAvatarImageView.anchor(top: nil, left: currentlyPlayingAlbumImageView.leftAnchor, bottom: currentlyPlayingAlbumImageView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 35, height: 35, enableInsets: false)
        contributorNameLabel.anchor(centerX: nil, centerY: contributorAvatarImageView.centerYAnchor, top: nil, left: contributorAvatarImageView.rightAnchor, bottom: nil, right: currentlyPlayingAlbumImageView.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        currentlyPlayingArtistAlbumLabel.anchor(top: nil, left: currentlyPlayingAlbumImageView.leftAnchor, bottom: contributorAvatarImageView.topAnchor, right: currentlyPlayingAlbumImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        currentlyPlayingSongNameLabel.anchor(top: nil, left: currentlyPlayingAlbumImageView.leftAnchor, bottom: currentlyPlayingArtistAlbumLabel.topAnchor, right: currentlyPlayingAlbumImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        trackProgressView.anchor(top: currentlyPlayingAlbumImageView.bottomAnchor, left: currentlyPlayingAlbumImageView.leftAnchor, bottom: nil, right: currentlyPlayingAlbumImageView.rightAnchor, paddingTop: 30, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        trackProgressLeftLabel.anchor(top: trackProgressView.bottomAnchor, left: trackProgressView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        trackProgressRightLabel.anchor(top: trackProgressView.bottomAnchor, left: nil, bottom: nil, right: trackProgressView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        currentlyPlayingGoLeftImageView.anchor(centerX: nil, centerY: view.centerYAnchor, top: nil, left: currentlyPlayingView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 15, height: 30, enableInsets: false)
        currentlyPlayingGoRightImageView.anchor(centerX: nil, centerY: view.centerYAnchor, top: nil, left: nil, bottom: nil, right: currentlyPlayingView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 15, height: 30, enableInsets: false)
        
        layoutSessionOptions()
        layoutPlaybackControls()
    }
    
    private func layoutSessionOptions() {
        currentlyPlayingView.addSubview(sessionsStackView)
        sessionsStackView.addArrangedSubview(UIView())
        sessionsStackView.addArrangedSubview(sessionOptionsVerticalStack)
        sessionsStackView.addArrangedSubview(UIView())
        sessionOptionsVerticalStack.addArrangedSubview(sessionOptionsHorizontalStack)
        sessionOptionsHorizontalStack.addArrangedSubview(joinAndListenButton)
        sessionOptionsHorizontalStack.addArrangedSubview(joinSessionButton)
        sessionOptionsVerticalStack.addArrangedSubview(listenPrivatelyButton)
        
        sessionsStackView.anchor(top: trackProgressLeftLabel.bottomAnchor, left: currentlyPlayingView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: currentlyPlayingView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        
        sessionOptionsVerticalStack.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        joinAndListenButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50, enableInsets: false)
        joinSessionButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50, enableInsets: false)
        listenPrivatelyButton.anchor(top: nil, left: listenPrivatelyButton.superview?.leftAnchor, bottom: nil, right: listenPrivatelyButton.superview?.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50, enableInsets: false)
        
        if playbackManagerView { didBeginPlayback() }
        updateSessionOptions()
    }
    
    private func layoutPlaybackControls() {
        playbackStackView.addArrangedSubview(UIView())
        
        playbackOptionsHorizontalStack.addArrangedSubview(currentlyPlayingAddTrackButton)
        playbackOptionsHorizontalStack.addArrangedSubview(pausePlayButton)
        playbackOptionsHorizontalStack.addArrangedSubview(skipButton)
        
        playbackStackView.addArrangedSubview(playbackOptionsHorizontalStack)
        playbackStackView.addArrangedSubview(UIView())
        
        pausePlayButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80, enableInsets: false)
        currentlyPlayingAddTrackButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80, enableInsets: false)
        skipButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80, enableInsets: false)
        
        
    }
    
    // MARK: - Private Functions
    
    private func configureInfoView() {
        guard let playlist = viewPlaylist else { return }
        playlistInfoView.rulesetID = playlist.ruleset_id
        playlistInfoView.updateInviteCode(code: playlist.invite_code)
        playlistInfoView.deleteButtonHandler = { [weak self] in self?.didTapDeleteButton() }
        
        playlistInfoView.addSubview(playlistInfoGoLeftImageView)
        
        playlistInfoGoLeftImageView.anchor(centerX: nil, centerY: view.centerYAnchor, top: nil, left: playlistInfoView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 15, height: 30, enableInsets: false)
    }
    
    private func fetchPlaylistQueue() {
        guard let playlist = viewPlaylist else { return }
        
        GroupSoundAPI.shared.fetchPlaylistTrackQueue(forPlaylist: playlist.playlist_id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.trackQueue = response.tracks
                    self?.configureCellModel()
                case .failure(let error):
                    print("Error with fetch track queue: \(error)")
                }
            }
        }
    }
    
    private func configureCellModel() {
        trackQueueCells.removeAll()
        for track in trackQueue {
            trackQueueCells.append(GroupSoundTrackQueueCellModel(trackName: track.song_title, trackArtist: track.song_artist, trackContributor: track.contributor_username, hasBeenPlayed: track.has_been_played))
        }
        DispatchQueue.main.async {
            self.queueTableView.reloadData()
        }
    }
    
    private func updateSessionOptions() {
        guard let playlist = viewPlaylist, let username = GroupSoundAuthManager.shared.username as? String else { return }
        joinSessionButton.removeTarget(nil, action: nil, for: .allEvents)
        if playlist.host_username == username {
            joinSessionButton.setTitle("Start Session", for: .normal)
            joinSessionButton.addTarget(self, action: #selector(didTapStartSessionButton), for: .touchUpInside)
            sessionOptionsHorizontalStack.removeArrangedSubview(joinAndListenButton)
        } else {
            joinSessionButton.setTitle("Join Session", for: .normal)
            joinSessionButton.addTarget(self, action: #selector(didTapJoinSessionButton), for: .touchUpInside)
            if playlist.playback_status == "inactive" {
                sessionOptionsVerticalStack.removeArrangedSubview(sessionOptionsHorizontalStack)
            }
        }
    }
    
    private func updatePlaylistData() {
        guard let playlist = viewPlaylist else { return }
        DispatchQueue.main.async { [weak self] in
            self?.playlistNameLabel.text = playlist.playlist_name
            self?.fetchPlaylistQueue()
        }
    }
    
    private func updatePlaylistData(withQueue tracks: [GroupSoundTrack]) {
        self.trackQueue = tracks
        self.configureCellModel()
    }
    
    private func updatePlaylistRuleset() {
        
    }
    
    // MARK: - Objective - C Functions
    
    @objc func returnToPreviousView() {
        trackQueueView.isHidden = true
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapListenPrivately() {
        guard let playlist = viewPlaylist else { return }
        PlaybackManager.shared.delegate = self
        playbackManagerView = true
        PlaybackManager.shared.beginPrivateListeningPlayback(forPlaylist: playlist)
    }
    
    @objc func didTapStartSessionButton() {
        print("Starting Session")
        guard let playlist = viewPlaylist else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let currentTrackAction = UIAlertAction(title: "Start Current Track", style: .default) { _ in
            
            ConnectionManager.shared.viewPort = self
            self.connectionManagerView = true
            ConnectionManager.shared.createConnection(toPlaylist: playlist)
            PlaybackManager.shared.delegate = self
            self.playbackManagerView = true
            PlaybackManager.shared.connectStartSession(forPlaylist: playlist)
        }
        let beginningTrackAction = UIAlertAction(title: "Restart Playlist", style: .default) { _ in
            PlaybackManager.shared.currentTrackIndex = 0
            
            ConnectionManager.shared.viewPort = self
            self.connectionManagerView = true
            ConnectionManager.shared.createConnection(toPlaylist: playlist)
            PlaybackManager.shared.delegate = self
            self.playbackManagerView = true
            PlaybackManager.shared.connectStartSession(forPlaylist: playlist)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(currentTrackAction)
        alert.addAction(beginningTrackAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapJoinSessionButton() {
        print("Starting Join")
        guard let playlist = viewPlaylist else { return }
        
        ConnectionManager.shared.viewPort = self
        connectionManagerView = true
        ConnectionManager.shared.createConnection(toPlaylist: playlist)
        didBeginPlayback()
    }
    
    @objc func didTapJoinAndListenButton() {
        print("Starting Join and Listen")
        guard let playlist = viewPlaylist else { return }
        
        ConnectionManager.shared.viewPort = self
        connectionManagerView = true
        ConnectionManager.shared.createConnection(toPlaylist: playlist)
        
        PlaybackManager.shared.delegate = self
        playbackManagerView = true
        PlaybackManager.shared.connectJoinedSession(forPlaylist: playlist)
    }
    
    @objc func didTapAddTrackButton() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.prompt = "Add songs to \(viewPlaylist?.playlist_name ?? "")"
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    @objc func didTapPausePlayButton() {
        PlaybackManager.shared.pausePlayCommandPressed()
    }
    
    @objc func didTapSkipButton() {
        PlaybackManager.shared.skipCommandPressed()
    }
    
    @objc func didTapDeleteButton() {
        let alert = UIAlertController(title: "Delete this playlist?", message: "This will remove the playlist for all users.\nThis cannot be undone.", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let id = self?.viewPlaylist?.playlist_id else { return }
            
            GroupSoundAPI.shared.deletePlaylist(withID: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case true:
                        self?.navigationController?.popViewController(animated: true)
                        self?.deletePlaylistHandler?()
                    case false:
                        print("Error deleting playlist")
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapRefreshTableViewButton() {
        ConnectionManager.shared.sendTestMesssage()
    }
    
}

// MARK: - PlaybackManagerViewPort

extension NowPlayingViewController: PlaybackManagerViewPort {
    
    func updateTrackQueue(trackQueue: [GroupSoundTrack]) {
        self.trackQueue = trackQueue
        configureCellModel()
    }
    
    func updateRuleset() {
        self.playlistInfoView.fetchRuleset()
    }
    
    func didChangePlaybackStatus(status: MPMusicPlaybackState) {
        switch status {
        case .playing:
            pausePlayButton.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        case .paused:
            pausePlayButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        default:
            print(status.rawValue)
        }
    }
    
    func updateTrack() {
        guard let currentlyPlayingTrack = PlaybackManager.shared.musicPlayer.nowPlayingItem else { return }
        currentlyPlayingSongNameLabel.text = currentlyPlayingTrack.title
        currentlyPlayingArtistAlbumLabel.text = "\(currentlyPlayingTrack.artist ?? "Artist") - \(currentlyPlayingTrack.albumTitle ?? "Album")"
        contributorNameLabel.text = PlaybackManager.shared.currentTrack?.contributor_username
        
        if let albumImage = currentlyPlayingTrack.artwork?.image(at: currentlyPlayingAlbumImageView.frame.size) {
            currentlyPlayingAlbumImageView.image = albumImage
        } else {
            AppleMusicAPI.shared.fetchTrack(withId: currentlyPlayingTrack.playbackStoreID) { [weak self] result in
                switch result {
                case .success(let track):
                    self?.currentlyPlayingAlbumImageView.downloaded(from: track.artworkURL)
                    break
                case .failure( _):
                    // Display unable to retreive album artwork
                    break
                }
            }
        }
        
        guard let currentIndex = PlaybackManager.shared.currentTrackIndex else { return }

        queueTableView.reloadRows(at: [IndexPath(row: currentIndex, section: 0)], with: .none)

        if currentIndex - 1 > -1 {
            queueTableView.reloadRows(at: [IndexPath(row: currentIndex - 1, section: 0)], with: .none)
        }
    }
    
    func didBeginPlayback() {
        print("Playback Began")
        
        sessionOptionsVerticalStack.isHidden = true
        sessionsStackView.removeArrangedSubview(sessionOptionsVerticalStack)
        sessionsStackView.insertArrangedSubview(playbackStackView, at: 1)
    }
    
    func didEndPlayback() {
        print("Playback Ended")
    }
}

// MARK: - ConnectinManagerViewPort

extension NowPlayingViewController: ConnectionManagerViewPort {
    func updateStatusLog(withStatus: String) {
        DispatchQueue.main.async { [weak self] in
            self?.playlistUpdateLog.textStorage.append(NSAttributedString(string: withStatus))
        }
    }
    
    func reloadStatusLog(withStatus: [String]) {
        DispatchQueue.main.async { [weak self] in
            for status in withStatus {
                self?.playlistUpdateLog.textStorage.append(NSAttributedString(string: status))
            }
        }
    }
}

// MARK: - UITableViewDelegate/DataSource

extension NowPlayingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackQueueCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupSoundTrackQueueCell", for: indexPath) as! GroupSoundTrackQueueCell
        cell.trackCellModel = trackQueueCells[indexPath.row]
//        cell.holdGestureHandler = handleCellLongPressGesture
        guard let currentTrackIndex = PlaybackManager.shared.currentTrackIndex else { return cell }
        
        let indexComparison = indexPath.row - currentTrackIndex
        if indexComparison == 0 { cell.cellType = .currentlyPlaying }
        else if indexComparison > 0 { cell.cellType = .enqueued }
        else { cell.cellType = .played }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Remove Song") { [weak self] action, view, handler in
            self?.removeTrack(track: (self?.trackQueue[indexPath.row])!)
        }
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    func removeTrack(track: GroupSoundTrack) {
        guard let playlist = viewPlaylist else { return }
        let trackRequestBody: [String: Any] = ["playlist_id": playlist.playlist_id, "song_id": track.song_id, "contributor_username": track.contributor_username, "date_added": track.date_added]
        GroupSoundAPI.shared.removeTrackFromPlaylist(requestBody: trackRequestBody) { [weak self] success in
            switch success {
            case true:
                if ConnectionManager.shared.playlist?.playlist_id == playlist.playlist_id { ConnectionManager.shared.send(event: .songQueueUpdate) }
                if PlaybackManager.shared.currentPlaylist?.playlist_id == playlist.playlist_id { PlaybackManager.shared.updateTrackQueueReceived() }
                else { self?.updatePlaylistData() }
            case false:
                print("Error removing track from playlist")
                // Perform response alert
                return
            }
        }
    }
}

// MARK: - MPMediaPickerDelegate

extension NowPlayingViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let track = mediaItemCollection.items.first
        
        guard let trackID = track?.playbackStoreID, let trackName = track?.title, let trackArtist = track?.artist, let trackDuration = track?.playbackDuration, let trackExplicit = track?.isExplicitItem, let playlist = viewPlaylist else {
            return
        }
        
        let trackJSON: [String: Any] = ["song_id": trackID, "service_provider": "apple_music", "song_title": trackName, "song_artist": trackArtist, "song_duration": trackDuration, "is_explicit": trackExplicit ? 1 : 0, "song_genre": "none"]
        let playlistTrackJSON: [String: Any] = ["playlist_id": playlist.playlist_id, "song_id": trackID, "contributor_username": GroupSoundAuthManager.shared.username ?? "", "has_been_played": 0, "date_added": Date().toSQLDateTimeString()]
        let httpBody = ["song": trackJSON, "playlistSong": playlistTrackJSON]
        
        GroupSoundAPI.shared.addTrackToPlaylist(requestBody: httpBody) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case true:
                    mediaPicker.dismiss(animated: true, completion: {
                        print("Updated Queue")
                        if ConnectionManager.shared.playlist?.playlist_id == playlist.playlist_id { ConnectionManager.shared.send(event: .songQueueUpdate) }
                        if PlaybackManager.shared.currentPlaylist?.playlist_id == playlist.playlist_id { PlaybackManager.shared.updateTrackQueueReceived() }
                        else { self?.updatePlaylistData() }
                    })
                case false:
                    // Display error
                    print("Error adding playlist track")
                }
            }
        }
    }
}
