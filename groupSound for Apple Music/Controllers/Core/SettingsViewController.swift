//
//  SettingsViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private var returnButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        button.tintColor = .white
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(returnToPreviousView), for: .touchUpInside)
        return button
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .right
        return label
    }()
    
    private let appleMusicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "apple_music_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let linkAppleMusicAccountButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Link Apple Music Account", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(didTapLinkAppleMusicAccount), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let appleMusicAccountConnectedLabel: UILabel = {
        let label = UILabel()
        label.text = "Account Connected"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 22)
        label.isHidden = true
        return label
    }()
    
    private var appleMusicLogoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Unlink Apple Music Account", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(didTapUnlinkAppleMusicAccount), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var logoutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.titleLabel?.font = .boldSystemFont(ofSize: 22)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitle("Log Out", for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutSubviews()
        displayAppleMusicAccount()
    }
    
    private func layoutSubviews() {
        view.addSubview(returnButton)
        view.addSubview(titleLabel)
        
        view.addSubview(appleMusicImageView)
        view.addSubview(linkAppleMusicAccountButton)
        view.addSubview(appleMusicAccountConnectedLabel)
        view.addSubview(appleMusicLogoutButton)
        
        view.addSubview(logoutButton)
        
        returnButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40, enableInsets: false)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: returnButton.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 40, enableInsets: false)
        
        appleMusicImageView.anchor(top: returnButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100, enableInsets: false)
        linkAppleMusicAccountButton.anchor(centerX: nil, centerY: appleMusicImageView.centerYAnchor, top: nil, left: appleMusicImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 50, enableInsets: false)
        appleMusicAccountConnectedLabel.anchor(centerX: nil, centerY: appleMusicImageView.centerYAnchor, top: appleMusicImageView.topAnchor, left: appleMusicImageView.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        appleMusicLogoutButton.anchor(top: appleMusicImageView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        
        logoutButton.anchor(top: appleMusicLogoutButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50, enableInsets: false)
    }
    
    private func displayAppleMusicAccount() {
        let isSignedIn = AppleAuthManager.shared.accountLinked
        linkAppleMusicAccountButton.isHidden = isSignedIn
        appleMusicAccountConnectedLabel.isHidden = !isSignedIn
        appleMusicLogoutButton.isHidden = !isSignedIn
    }
    
    @objc func didTapLinkAppleMusicAccount() {
        AppleAuthManager.shared.getUserToken { [weak self] success in
            if success {
                AppleAuthManager.shared.fetchStoreFrontID() { result in
                    switch result {
                    case .success(_):
                        self?.displayAppleMusicAccount()
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc func didTapUnlinkAppleMusicAccount() {
        
    }
    
    @objc func returnToPreviousView() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapLogoutButton() {
        
    }
}
