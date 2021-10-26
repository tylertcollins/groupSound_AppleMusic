//
//  LogInViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit

class LogInViewController: UIViewController {
    
    // MARK: - Private Objects
    
    
    /// Centered Title Label
    private let groupsoundTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "GroupSound"
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    /// Label for listing the version number under the Title
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 0.0.1 Alpha"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    
    /// Textfield for Username entry
    private let usernameTextField: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 0.0;
        textfield.layer.borderColor = UIColor.white.cgColor
        textfield.backgroundColor = .black
        let whitePlaceholderText = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textfield.attributedPlaceholder = whitePlaceholderText
        textfield.textColor = .white
        textfield.layer.borderWidth = 0.5
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.tag = 0
        return textfield
    }()
    
    /// Textfield for Password Entry
    private let passwordTextField: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 0.0;
        textfield.layer.borderColor = UIColor.white.cgColor
        textfield.backgroundColor = .black
        textfield.textColor = .white
        textfield.layer.borderWidth = 0.5
        let whitePlaceholderText = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textfield.attributedPlaceholder = whitePlaceholderText
        textfield.isSecureTextEntry = true
        textfield.tag = 1
        return textfield
    }()
    
    /// Appears to inform user of problem logging in
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        label.text = "Username or Password is incorrect"
        return label
    }()
    
    /// Button to handle signing in user
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        return button
    }()
    
    /// Button to segue user to Sign In View
    private let signUpButton: UIButton = {
       let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Functions
    
    
    /// Called when view is loaded in
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        layoutSubviews()
    }
    
    /// Called when view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// Adds UI objects to view and attaches anchors to layout view
    private func layoutSubviews() {
        view.addSubview(groupsoundTitleLabel)
        view.addSubview(versionLabel)
        view.addSubview(errorLabel)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let padding: CGFloat = 16
        
        groupsoundTitleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: padding, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        versionLabel.anchor(top: groupsoundTitleLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        usernameTextField.anchor(top: versionLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 100, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 40, enableInsets: false)
        passwordTextField.anchor(top: usernameTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: padding, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 40, enableInsets: false)
        errorLabel.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: usernameTextField.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: padding, paddingBottom: 5, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        signInButton.anchor(top: passwordTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: padding, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 50, enableInsets: false)
        signUpButton.anchor(top: signInButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 30, enableInsets: false)
    }
    
    /// Calls signInUser API function and handles and displays error message or
    /// page segue based on call response
    /// - Parameters:
    ///   - username: The user's inputed value in the username text field
    ///   - password: The user's inputed value in the password text field
    private func signInUser(username: String, password: String) {
        GroupSoundAPI.shared.authorizeUser(withUsername: username, withPassword: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success( _):
                    self?.moveToRootController()
                case .failure(let error):
                    self?.errorLabel.isHidden = false
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
    
    
    /// Creates instance and pushes to root view controller (Playlist View)
    private func moveToRootController() {
        let vc = PlaylistsViewController()
//        vc.navigationItem.largeTitleDisplayMode = .automatic
//        vc.navigationItem.setHidesBackButton(true, animated: false)
//        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.viewControllers.remove(at: 0)
    }
    
    // MARK: - Objective-C Functions
    
    
    /// Verfies username and password inputs before calling sign in user api endpoint
    @objc func didTapSignIn() {
        
        if usernameTextField.text?.isEmpty ?? true {
            usernameTextField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            usernameTextField.layer.borderColor = UIColor.gray.cgColor
        }
        
        if passwordTextField.text?.isEmpty ?? true {
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            passwordTextField.layer.borderColor = UIColor.gray.cgColor
        }
        
        guard let username = usernameTextField.text, let password = passwordTextField.text, !username.isEmpty, !password.isEmpty else {
            return
        }
        
        signInUser(username: username, password: password)
    }
    
    /// Segues user to sign up view
    @objc func didTapSignUp() {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Extension: UITextFieldDelegate

extension LogInViewController: UITextFieldDelegate {
    
    
    /// Handles tapping return to start input for next textfield or dismissing keyboard
    /// - Parameter textField: The currently being edited textfield
    /// - Returns: If textfield should return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
         nextField.becomeFirstResponder()
      } else {
         textField.resignFirstResponder()
      }
        
      return false
   }
}

