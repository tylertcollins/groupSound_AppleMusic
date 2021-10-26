//
//  SplashScreenViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 8/2/21.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    private var email: String?
    private var username: String?
    private var password: String?
    
    private var userCreated: Bool = false
    
    private let backgroundBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let effectview = UIVisualEffectView(effect: blur)
        effectview.isHidden = true
        return effectview
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "GroupSound"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 40)
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Contribute. Vote. Listen."
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .left
        return label
    }()
    
    private let imageViewCarousel: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.isPagingEnabled = true
        scrollview.showsHorizontalScrollIndicator = false
        return scrollview
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "splashscreenph")
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(hex: "804000")
        button.addTarget(self, action: #selector(showLoginView), for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(hex: "004080")
        button.addTarget(self, action: #selector(showSignUpView), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Login/Sign Up View
    
    private let loginSignUpContentView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(hex: "004080")
        return view
    }()
    
    private let loginSignUpTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log In"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .left
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 5;
        textfield.font = .systemFont(ofSize: 24)
        textfield.layer.borderColor = UIColor.white.cgColor
        textfield.backgroundColor = .black
        let whitePlaceholderText = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textfield.attributedPlaceholder = whitePlaceholderText
        textfield.textColor = .white
        textfield.layer.borderWidth = 0.5
        textfield.keyboardType = .emailAddress
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.tag = 0
        return textfield
    }()
    
    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Email is already in use"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    private let usernameTextField: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 5;
        textfield.font = .systemFont(ofSize: 24)
        textfield.layer.borderColor = UIColor.white.cgColor
        textfield.backgroundColor = .black
        let whitePlaceholderText = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textfield.attributedPlaceholder = whitePlaceholderText
        textfield.textColor = .white
        textfield.layer.borderWidth = 0.5
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.tag = 1
        return textfield
    }()
    
    private let usernameErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Username is not available"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 5;
        textfield.font = .systemFont(ofSize: 24)
        textfield.layer.borderColor = UIColor.white.cgColor
        textfield.backgroundColor = .black
        textfield.textColor = .white
        textfield.layer.borderWidth = 0.5
        let whitePlaceholderText = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textfield.attributedPlaceholder = whitePlaceholderText
        textfield.isSecureTextEntry = true
        textfield.tag = 2
        return textfield
    }()
    
    private let loginErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Invalid Login Credentials"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let loginSignUpViewButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(hex: "408000")
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Sign Up View

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        layoutSubviews()
        
        hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func layoutSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(backgroundBlurView)
        view.addSubview(descriptionLabel)
        view.addSubview(titleLabel)
        
        backgroundImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        loginButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 50, enableInsets: false)
        signUpButton.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: loginButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 50, enableInsets: false)
        backgroundBlurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
    }
    
    private func layoutLoginView() {
        view.addSubview(loginSignUpContentView)
        view.addSubview(cancelButton)
        loginSignUpContentView.addSubview(loginSignUpTitleLabel)
        loginSignUpContentView.addSubview(usernameLabel)
        loginSignUpContentView.addSubview(usernameTextField)
        loginSignUpContentView.addSubview(passwordLabel)
        loginSignUpContentView.addSubview(passwordTextField)
        loginSignUpContentView.addSubview(loginSignUpViewButton)
        loginSignUpContentView.addSubview(loginErrorLabel)
        
        loginSignUpTitleLabel.text = "Log In"
        loginSignUpViewButton.setTitle("Log In", for: .normal)
        loginSignUpViewButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        loginErrorLabel.isHidden = true
        
        loginSignUpContentView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor,top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        loginSignUpTitleLabel.anchor(top: loginSignUpContentView.topAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        usernameLabel.anchor(top: loginSignUpTitleLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        usernameTextField.anchor(top: usernameLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        passwordLabel.anchor(top: usernameTextField.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        passwordTextField.anchor(top: passwordLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        loginErrorLabel.anchor(top: passwordTextField.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        loginSignUpViewButton.anchor(top: loginErrorLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: loginSignUpContentView.bottomAnchor, right: loginSignUpContentView.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        cancelButton.anchor(centerX: loginSignUpContentView.centerXAnchor, centerY: nil, top: loginSignUpContentView.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
    }
    
    private func layoutSignUpView() {
        view.addSubview(loginSignUpContentView)
        view.addSubview(cancelButton)
        loginSignUpContentView.addSubview(emailLabel)
        loginSignUpContentView.addSubview(emailTextField)
        loginSignUpContentView.addSubview(emailErrorLabel)
        loginSignUpContentView.addSubview(loginSignUpTitleLabel)
        loginSignUpContentView.addSubview(usernameLabel)
        loginSignUpContentView.addSubview(usernameTextField)
        loginSignUpContentView.addSubview(usernameErrorLabel)
        loginSignUpContentView.addSubview(passwordLabel)
        loginSignUpContentView.addSubview(passwordTextField)
        loginSignUpContentView.addSubview(loginSignUpViewButton)
        
        loginSignUpTitleLabel.text = "Sign Up"
        loginSignUpViewButton.setTitle("Sign Up", for: .normal)
        loginSignUpViewButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        emailErrorLabel.isHidden = true
        usernameErrorLabel.isHidden = true
        
        loginSignUpContentView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor,top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        loginSignUpTitleLabel.anchor(top: loginSignUpContentView.topAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        emailLabel.anchor(top: loginSignUpTitleLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        emailTextField.anchor(top: emailLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        emailErrorLabel.anchor(top: emailTextField.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        usernameLabel.anchor(top: emailErrorLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        usernameTextField.anchor(top: usernameLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        usernameErrorLabel.anchor(top: usernameTextField.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        passwordLabel.anchor(top: usernameErrorLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        passwordTextField.anchor(top: passwordLabel.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40, enableInsets: false)
        loginSignUpViewButton.anchor(top: passwordTextField.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: loginSignUpContentView.bottomAnchor, right: loginSignUpContentView.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0, enableInsets: false)
        cancelButton.anchor(centerX: loginSignUpContentView.centerXAnchor, centerY: nil, top: loginSignUpContentView.bottomAnchor, left: loginSignUpContentView.leftAnchor, bottom: nil, right: loginSignUpContentView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
    }
    
    private func signInUser(username: String, password: String) {
        GroupSoundAPI.shared.authorizeUser(withUsername: username, withPassword: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success( _):
                    self?.moveToRootController()
                case .failure(let error):
                    self?.loginErrorLabel.isHidden = false
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func checkEmail(email: String) {
        GroupSoundAPI.shared.emailAvailable(email) { [weak self] available in
            DispatchQueue.main.async {
                switch available {
                case true:
                    self?.emailErrorLabel.isHidden = true
                    self?.email = email
                    self?.createUser()
                case false:
                    self?.emailErrorLabel.isHidden = false
                }
            }
        }
    }
    
    private func checkUsername(username: String) {
        GroupSoundAPI.shared.usernameAvailable(username) { [weak self] available in
            DispatchQueue.main.async {
                switch available {
                case true:
                    self?.usernameErrorLabel.isHidden = true
                    self?.username = username
                    self?.createUser()
                case false:
                    self?.usernameErrorLabel.isHidden = false
                }
            }
        }
    }
    
    private func createUser() {
        
        guard let username = username, let email = email, let password = password, !userCreated else { return }
        
        userCreated = true
        
        GroupSoundAPI.shared.createUser(withEmail: email, withUsername: username, withPassword: password) { [weak self] user in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Account Created!", message: "CONGRATS! Your GroupSound account has been created. Please log in to access your account.", preferredStyle: .alert)
                let continueAction = UIAlertAction(title: "Return to Log In", style: .default) { _ in
                    self?.didTapCancelButton()
                }
                
                alert.addAction(continueAction)
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func moveToRootController() {
        let vc = PlaylistsViewController()
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.viewControllers.remove(at: 0)
    }
    
    @objc func showLoginView() {
        
        layoutLoginView()
        
        loginSignUpContentView.layer.opacity = 0.0
        backgroundBlurView.layer.opacity = 0.0
        cancelButton.layer.opacity = 0.0
        
        loginSignUpContentView.isHidden = false
        backgroundBlurView.isHidden = false
        cancelButton.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.loginSignUpContentView.layer.opacity = 1.0
            self.backgroundBlurView.layer.opacity = 1.0
            self.cancelButton.layer.opacity = 1.0
        }
        
//        usernameTextField.becomeFirstResponder()
    }
    
    @objc func didTapLoginButton() {
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
    
    @objc func showSignUpView() {
        
        layoutSignUpView()
        
        loginSignUpContentView.layer.opacity = 0.0
        backgroundBlurView.layer.opacity = 0.0
        cancelButton.layer.opacity = 0.0
        
        loginSignUpContentView.isHidden = false
        backgroundBlurView.isHidden = false
        cancelButton.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.loginSignUpContentView.layer.opacity = 1.0
            self.backgroundBlurView.layer.opacity = 1.0
            self.cancelButton.layer.opacity = 1.0
        }
        
//        emailTextField.becomeFirstResponder()
    }
    
    @objc func didTapSignUpButton() {
        self.email = nil
        self.username = nil
        self.password = nil
        
        if emailTextField.text?.isEmpty ?? true {
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            emailTextField.layer.borderColor = UIColor.gray.cgColor
        }
        
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
        
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        self.password = password
        checkEmail(email: email)
        checkUsername(username: username)
    }
    
    @objc func didTapCancelButton() {
        
        self.dismissKeyboard()
        
        UIView.animate(withDuration: 0.5, animations: ({
            self.loginSignUpContentView.layer.opacity = 0.0
            self.backgroundBlurView.layer.opacity = 0.0
            self.cancelButton.layer.opacity = 0.0
        }), completion: ({ _ in
            self.loginSignUpContentView.isHidden = true
            self.backgroundBlurView.isHidden = true
            self.cancelButton.isHidden = true
            self.loginSignUpContentView.removeConstraints(self.loginSignUpContentView.constraints)
            for view in self.loginSignUpContentView.subviews { view.removeFromSuperview() }
            self.loginSignUpViewButton.removeTarget(nil, action: nil, for: .allEvents)
            self.passwordTextField.text = ""
            self.usernameTextField.text = ""
            self.emailTextField.text = ""
        }))
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 2
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension SplashScreenViewController: UITextFieldDelegate {
    
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
