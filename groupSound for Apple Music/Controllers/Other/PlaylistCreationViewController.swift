//
//  PlaylistCreationViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/23/21.
//

import UIKit

class PlaylistCreationViewController: UIViewController {
    
    public var playlistCreated: (() -> Void)?
    
    private let viewTitles: [String] = ["Name Your Playlist", "Track Skipping", "Queue Order", "Track Restrictions", "Playlist Limits"]
    
    private var viewIndex = 0
    
    private let backgroundGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: "9799BA").cgColor, UIColor(hex: "F9E1E0").cgColor]
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
    
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.isPagingEnabled = true
        scrollview.alwaysBounceVertical = false
        scrollview.alwaysBounceHorizontal = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.canCancelContentTouches = false
        return scrollview
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private let viewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Name Your Playlist"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 27)
        return label
    }()
    
    private let viewInfoButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        button.setTitle("", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let goLeftImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "chevron.left")
        imageview.tintColor = .white
        imageview.contentMode = .scaleToFill
        imageview.isHidden = true
        return imageview
    }()
    
    private let goRightImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "chevron.right")
        imageview.tintColor = .white
        imageview.contentMode = .scaleToFill
        imageview.isHidden = false
        return imageview
    }()
    
    private let createPlayistButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Default Playlist", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didTapCreatePlaylistButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - PlaylistNameView
    
    private let playlistNameView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let playlistNameTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Playlist Name"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    // MARK: - PlaylistSkippingView
    
    private let playlistSkippingView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let playlistSkipTypeTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Skip Type"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    private let skipTypes = ["Value", "Percent", "No Skips Allowed"]
    
    private let skipTypePicker: UIPickerView = {
        let pickerview = UIPickerView()
        return pickerview
    }()
    
    private let playlistSkipAmountTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Skip Amount"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    // MARK: - PlaylistQueueView
    
    private let playlistQueueView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let playlistOrderTypeTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Queue Order Type"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    private let orderTypes = ["ABC", "Time"]
    
    private let orderTypePicker: UIPickerView = {
        let pickerview = UIPickerView()
        return pickerview
    }()
    
    private let playlistAllowRepeatsLabel: UILabel = {
        let label = UILabel()
        label.text = "Allow Repeats"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 35, weight: .medium)
        return label
    }()
    
    private let playlistAllowRepeatsSwitch: UISwitch = {
        let uiswitch = UISwitch()
        return uiswitch
    }()
    
    // MARK: - PlaylistRestrictionsView
    
    private let playlistRestrictionsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let playlistDurationLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Track Duration Limits"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 35, weight: .medium)
        return label
    }()
    
    private let playlistDurationRangeSlider: RangeSeekSlider = {
        let slider = RangeSeekSlider()
        slider.colorBetweenHandles = .white
        slider.tintColor = .lightGray
        slider.handleColor = .white
        slider.hideLabels = true
        slider.handleDiameter = 25
        slider.lineHeight = 5
        return slider
    }()
    
    private let minimumDurationLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "No Limit"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let maximumDurationLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "No Limit"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let playlistAllowExplicitLabel: UILabel = {
        let label = UILabel()
        label.text = "Allow Explicit Tracks"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 35, weight: .medium)
        return label
    }()
    
    private let playlistAllowExplicitSwitch: UISwitch = {
        let uiswitch = UISwitch()
        return uiswitch
    }()
    
    // MARK: - PlaylistLimitsView
    
    private let playlistLimitsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let playlistMaxUsersTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Max Users"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    private let playlistMaxQueueTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Max Queue Size"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    private let playlistMaxContributionTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Max Contributions"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()
    
    private let playlistMaxSingleContributionTextfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Contibution Size"
        textfield.textAlignment = .center
        textfield.font = .systemFont(ofSize: 35, weight: .medium)
        textfield.backgroundColor = .systemBlue
        textfield.layer.cornerRadius = 0
        return textfield
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        configurePickerViews()
        layoutSubviews()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if scrollView.contentSize.height != view.safeAreaLayoutGuide.layoutFrame.height {
            scrollView.contentSize = CGSize(width: view.frame.width * 5, height: view.safeAreaLayoutGuide.layoutFrame.height)
        }
    }
    
    private func configurePickerViews() {
        skipTypePicker.delegate = self
        skipTypePicker.dataSource = self
        playlistSkipTypeTextfield.inputView = skipTypePicker
        
        orderTypePicker.delegate = self
        orderTypePicker.dataSource = self
        playlistOrderTypeTextfield.inputView = orderTypePicker
    }

    private func layoutSubviews() {
        backgroundGradient.frame = view.bounds
        view.layer.addSublayer(backgroundGradient)
        
        view.addSubview(backgroundBlurView)
        backgroundBlurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        view.addSubview(scrollView)
        view.addSubview(cancelButton)
        view.addSubview(viewTitleLabel)
        view.addSubview(viewInfoButton)
        view.addSubview(goLeftImageView)
        view.addSubview(goRightImageView)
        view.addSubview(createPlayistButton)
        
        scrollView.addSubview(playlistNameView)
        scrollView.addSubview(playlistSkippingView)
        scrollView.addSubview(playlistQueueView)
        scrollView.addSubview(playlistRestrictionsView)
        scrollView.addSubview(playlistLimitsView)
        
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 40, height: 40, enableInsets: false)
        viewTitleLabel.anchor(centerX: view.centerXAnchor, centerY: nil, top: cancelButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        viewInfoButton.anchor(centerX: view.centerXAnchor, centerY: nil, top: viewTitleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25, enableInsets: false)
        goLeftImageView.anchor(centerX: nil, centerY: view.centerYAnchor, top: nil, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 15, height: 30, enableInsets: false)
        goRightImageView.anchor(centerX: nil, centerY: view.centerYAnchor, top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 15, height: 30, enableInsets: false)
        createPlayistButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 50, enableInsets: false)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        scrollView.contentSize = CGSize(width: view.frame.width * 5, height: view.safeAreaLayoutGuide.layoutFrame.height)
        scrollView.delegate = self
        
        playlistNameView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.contentSize.height)
        playlistSkippingView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.contentSize.height)
        playlistQueueView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: scrollView.contentSize.height)
        playlistRestrictionsView.frame = CGRect(x: view.frame.width * 3, y: 0, width: view.frame.width, height: scrollView.contentSize.height)
        playlistLimitsView.frame = CGRect(x: view.frame.width * 4, y: 0, width: view.frame.width, height: scrollView.contentSize.height)
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        layoutPlaylistNameView()
        layoutPlaylistSkipView()
        layoutPlaylistQueueView()
        layoutPlaylistRestrictionsView()
        layoutPlaylistLimitsView()
    }
    
    private func layoutPlaylistNameView() {
        playlistNameView.addSubview(playlistNameTextfield)
        
        playlistNameTextfield.delegate = self
        
        playlistNameTextfield.anchor(centerX: playlistNameView.centerXAnchor, centerY: nil, top: nil, left: playlistNameView.leftAnchor, bottom: view.centerYAnchor, right: playlistNameView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 20, paddingRight: 25, width: 0, height: 50, enableInsets: false)
    }
    
    private func layoutPlaylistSkipView() {
        playlistSkippingView.addSubview(playlistSkipAmountTextfield)
        playlistSkippingView.addSubview(playlistSkipTypeTextfield)
        
        playlistSkipTypeTextfield.delegate = self
        playlistSkipAmountTextfield.delegate = self
        
        playlistSkipAmountTextfield.anchor(centerX: playlistSkippingView.centerXAnchor, centerY: nil, top: view.centerYAnchor, left: playlistSkippingView.leftAnchor, bottom: nil, right: playlistSkippingView.rightAnchor, paddingTop: -20, paddingLeft: 25, paddingBottom: 20, paddingRight: 25, width: 0, height: 50, enableInsets: false)
        playlistSkipTypeTextfield.anchor(centerX: playlistSkippingView.centerXAnchor, centerY: nil, top: nil, left: playlistSkippingView.leftAnchor, bottom: playlistSkipAmountTextfield.topAnchor, right: playlistSkippingView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 50, paddingRight: 25, width: 0, height: 50, enableInsets: false)
    }
    
    private func layoutPlaylistQueueView() {
        playlistQueueView.addSubview(playlistAllowRepeatsSwitch)
        playlistQueueView.addSubview(playlistAllowRepeatsLabel)
        playlistQueueView.addSubview(playlistOrderTypeTextfield)
        
        playlistOrderTypeTextfield.delegate = self
        
        playlistAllowRepeatsSwitch.anchor(centerX: playlistQueueView.centerXAnchor, centerY: nil, top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 25, paddingBottom: 20, paddingRight: 25, width: 0, height: 0, enableInsets: false)
        playlistAllowRepeatsLabel.anchor(centerX: playlistQueueView.centerXAnchor, centerY: nil, top: nil, left: playlistQueueView.leftAnchor, bottom: playlistAllowRepeatsSwitch.topAnchor, right: playlistQueueView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 5, paddingRight: 25, width: 0, height: 50, enableInsets: false)
        playlistOrderTypeTextfield.anchor(centerX: playlistQueueView.centerXAnchor, centerY: nil, top: nil, left: playlistQueueView.leftAnchor, bottom: playlistAllowRepeatsLabel.topAnchor, right: playlistQueueView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 50, paddingRight: 25, width: 0, height: 50, enableInsets: false)
    }
    
    private func layoutPlaylistRestrictionsView() {
        playlistRestrictionsView.addSubview(playlistAllowExplicitSwitch)
        playlistRestrictionsView.addSubview(playlistAllowExplicitLabel)
        playlistRestrictionsView.addSubview(minimumDurationLimitLabel)
        playlistRestrictionsView.addSubview(maximumDurationLimitLabel)
        playlistRestrictionsView.addSubview(playlistDurationRangeSlider)
        playlistRestrictionsView.addSubview(playlistDurationLimitLabel)
        
        playlistDurationRangeSlider.delegate = self
        
        playlistAllowExplicitSwitch.anchor(centerX: playlistRestrictionsView.centerXAnchor, centerY: nil, top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 25, paddingBottom: 20, paddingRight: 25, width: 0, height: 0, enableInsets: false)
        playlistAllowExplicitLabel.anchor(centerX: playlistRestrictionsView.centerXAnchor, centerY: nil, top: nil, left: playlistRestrictionsView.leftAnchor, bottom: playlistAllowExplicitSwitch.topAnchor, right: playlistRestrictionsView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 5, paddingRight: 25, width: 0, height: 50, enableInsets: false)
        minimumDurationLimitLabel.anchor(top: nil, left: playlistRestrictionsView.leftAnchor, bottom: playlistAllowExplicitLabel.topAnchor, right: playlistRestrictionsView.centerXAnchor, paddingTop: 0, paddingLeft: 35, paddingBottom: 50, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        maximumDurationLimitLabel.anchor(top: nil, left: playlistRestrictionsView.centerXAnchor, bottom: playlistAllowExplicitLabel.topAnchor, right: playlistRestrictionsView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 35, width: 0, height: 0, enableInsets: false)
        playlistDurationRangeSlider.anchor(centerX: playlistRestrictionsView.centerXAnchor, centerY: nil, top: nil, left: playlistRestrictionsView.leftAnchor, bottom: minimumDurationLimitLabel.topAnchor, right: playlistRestrictionsView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 5, paddingRight: 25, width: 0, height: 0, enableInsets: false)
        playlistDurationLimitLabel.anchor(centerX: playlistRestrictionsView.centerXAnchor, centerY: nil, top: nil, left: playlistRestrictionsView.leftAnchor, bottom: playlistDurationRangeSlider.topAnchor, right: playlistRestrictionsView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: 0, enableInsets: false)
    }
    
    private func layoutPlaylistLimitsView() {
        playlistLimitsView.addSubview(playlistMaxSingleContributionTextfield)
        playlistLimitsView.addSubview(playlistMaxContributionTextfield)
        playlistLimitsView.addSubview(playlistMaxQueueTextfield)
        playlistLimitsView.addSubview(playlistMaxUsersTextfield)
        
        playlistMaxSingleContributionTextfield.delegate = self
        playlistMaxContributionTextfield.delegate = self
        playlistMaxQueueTextfield.delegate = self
        playlistMaxUsersTextfield.delegate = self
        
        playlistMaxSingleContributionTextfield.anchor(centerX: playlistLimitsView.centerXAnchor, centerY: nil, top: view.centerYAnchor, left: playlistLimitsView.leftAnchor, bottom: nil, right: playlistLimitsView.rightAnchor, paddingTop: 100, paddingLeft: 25, paddingBottom: 20, paddingRight: 25, width: 0, height: 50, enableInsets: false)
        playlistMaxContributionTextfield.anchor(centerX: playlistLimitsView.centerXAnchor, centerY: nil, top: nil, left: playlistLimitsView.leftAnchor, bottom: playlistMaxSingleContributionTextfield.topAnchor, right: playlistLimitsView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 50, paddingRight: 25, width: 0, height: 50, enableInsets: false)
        playlistMaxQueueTextfield.anchor(centerX: playlistLimitsView.centerXAnchor, centerY: nil, top: nil, left: playlistLimitsView.leftAnchor, bottom: playlistMaxContributionTextfield.topAnchor, right: playlistLimitsView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 50, paddingRight: 25, width: 0, height: 50, enableInsets: false)
        playlistMaxUsersTextfield.anchor(centerX: playlistLimitsView.centerXAnchor, centerY: nil, top: nil, left: playlistLimitsView.leftAnchor, bottom: playlistMaxQueueTextfield.topAnchor, right: playlistLimitsView.rightAnchor, paddingTop: 0, paddingLeft: 25, paddingBottom: 50, paddingRight: 25, width: 0, height: 50, enableInsets: false)
    }
    
    private func validateFields() -> Bool {
        var valid = true
        
        if playlistNameTextfield.text?.isEmpty ?? true {
            playlistNameTextfield.layer.backgroundColor = UIColor.systemRed.cgColor
            valid = false
            let alert = UIAlertController(title: "Playlist Name Required", message: "A name is required to create a playlist", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            playlistNameTextfield.layer.backgroundColor = UIColor.black.cgColor
        }
        
        return valid
    }
    
    private func createPlaylist() {
        var httpBody = generateRulesetJSON()
        httpBody["playlist_name"] = playlistNameTextfield.text
        httpBody["host_username"] = GroupSoundAuthManager.shared.username
        
        GroupSoundAPI.shared.createPlaylist(withRuleset: httpBody) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    // Display alert and return on dismiss
                    let alert = UIAlertController(title: "Playlist Created!", message: "Your playlist has been created. Start adding and listening to tracks from your list of playlists.", preferredStyle: .alert)
                    let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
                        self?.didTapCancelButton()
                    }
                    alert.addAction(continueAction)
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error Encountered", message: "There was a problem creating the playlist. Check your connection and try again.", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alert.addAction(dismissAction)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func generateRulesetJSON() -> [String: Any] {
        var rulesetJSON: [String: Any] = [:]
        
        if let skipType = playlistSkipTypeTextfield.text {
            switch skipType {
            case "Value":
                rulesetJSON["skip_type"] = "value"
                guard let value = playlistSkipTypeTextfield.text, !value.isEmpty else {
                    rulesetJSON["skips_required"] = 1
                    break
                }
                rulesetJSON["skips_required"] = Int(value)
            case "Percent":
                rulesetJSON["skip_type"] = "percent"
                guard let value = playlistSkipAmountTextfield.text, !value.isEmpty else {
                    rulesetJSON["skips_required"] = 50
                    break
                }
                rulesetJSON["skips_required"] = Int(value)
            default:
                break
            }
        }
        
        if let orderType = playlistOrderTypeTextfield.text {
            switch orderType {
            case "ABC":
                rulesetJSON["order_type"] = "abc"
            case "Time":
                rulesetJSON["order_type"] = "time"
            default:
                break
            }
        }
        
        rulesetJSON["song_min_duration"] = Int(playlistDurationRangeSlider.minValue * 600)
        if Int(playlistDurationRangeSlider.maxValue * 600) != 600 {
            rulesetJSON["song_max_duration"] = Int(playlistDurationRangeSlider.maxValue * 600)
        }
        
        if let maxUsers = playlistMaxUsersTextfield.text, !maxUsers.isEmpty {
            rulesetJSON["max_users"] = Int(maxUsers)
        }
        
        if let maxSongCount = playlistMaxQueueTextfield.text, !maxSongCount.isEmpty {
            rulesetJSON["max_song_count"] = Int(maxSongCount)
        }
        
        if let maxUserSongCount = playlistMaxContributionTextfield.text, !maxUserSongCount.isEmpty {
            rulesetJSON["max_user_song_count"] = Int(maxUserSongCount)
        }
        
        if let maxSongsAdd = playlistMaxSingleContributionTextfield.text, !maxSongsAdd.isEmpty {
            rulesetJSON["max_songs_add"] = Int(maxSongsAdd)
        }
        
        rulesetJSON["allow_explict"] = playlistAllowExplicitSwitch.isOn ? 1 : 0
        rulesetJSON["allow_repeats"] = playlistAllowRepeatsSwitch.isOn ? 1 : 0
        
        return rulesetJSON
    }
    
    @objc func didTapCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapCreatePlaylistButton() {
        guard validateFields() else { return }
        createPlaylist()
    }
}

extension PlaylistCreationViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        self.viewTitleLabel.text = self.viewTitles[self.viewIndex]
        goLeftImageView.isHidden = viewIndex == 0
        goRightImageView.isHidden = viewIndex == 4
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
}

extension PlaylistCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField != playlistNameTextfield {
            createPlayistButton.setTitle("Create Custom Playlist", for: .normal)
        }
    }
}

extension PlaylistCreationViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        let maxLimit = 600.0 //Ten Minutes

        let minDuration = Double(minValue) * 0.01
        let maxDuration = Double(maxValue) * 0.01

        var minDurationText = ""
        var maxDurationText = ""

        if minDuration == 0 {
            minDurationText = "No Limit"
        } else {
            let minutes = (Int(maxLimit * minDuration) % 3600) / 60
            let seconds = String(format: "%02d", arguments: [(Int(maxLimit * minDuration) % 3600) % 60])
            minDurationText = "\(minutes):\(seconds)"
        }

        if maxDuration == 1 {
            maxDurationText = "No Limit"
        } else {
            let minutes = (Int(maxLimit * maxDuration) % 3600) / 60
            let seconds = String(format: "%02d", arguments: [(Int(maxLimit * maxDuration) % 3600) % 60])
            maxDurationText = "\(minutes):\(seconds)"
        }

        minimumDurationLimitLabel.text = minDurationText
        maximumDurationLimitLabel.text = maxDurationText
    }
}

extension PlaylistCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case skipTypePicker:
            return skipTypes.count
        case orderTypePicker:
            return orderTypes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case skipTypePicker:
            return skipTypes[row]
        case orderTypePicker:
            return orderTypes[row]
        default:
            return "Error"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case skipTypePicker:
            playlistSkipTypeTextfield.text = skipTypes[row]
            playlistSkipAmountTextfield.isEnabled = (skipTypes[row] != "No Skips Allowed")
        case orderTypePicker:
            playlistOrderTypeTextfield.text = orderTypes[row]
        default:
            break
        }
    }
}
