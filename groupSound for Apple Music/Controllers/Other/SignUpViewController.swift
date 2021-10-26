//
//  SignUpViewController.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/21/21.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private var email: String?
    private var username: String?
    private var password: String?
    
    private var userCreated: Bool = false
    
    private let emailTextField: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 0.0;
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 0.5
        textfield.placeholder = "Email"
        textfield.keyboardType = .emailAddress
        textfield.tag = 0
        return textfield
    }()
    
    private let usernameTextfield: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 0.0;
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 0.5
        textfield.placeholder = "Username"
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.tag = 1
        return textfield
    }()
    
    private let passwordTextfield: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 0.0;
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 0.5
        textfield.placeholder = "Password"
        textfield.isSecureTextEntry = true
        textfield.tag = 1
        return textfield
    }()
    
    private let confirmPasswordTextfield: UITextField = {
        let textfield = UITextField()
        textfield.setPaddingPoints(left: 5, right: 5)
        textfield.layer.cornerRadius = 0.0;
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 0.5
        textfield.placeholder = "Confirm Password"
        textfield.isSecureTextEntry = true
        textfield.tag = 1
        return textfield
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to GroupSound"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        label.text = "Passwords do not match"
        return label
    }()
    
    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        label.text = "Account already exists"
        return label
    }()
    
    private let usernameErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        label.text = "This username is not available"
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(returnToSignIn), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureSubviews()
    }
    
    private func configureSubviews() {
        view.addSubview(welcomeLabel)
        view.addSubview(emailTextField)
        view.addSubview(usernameTextfield)
        view.addSubview(passwordTextfield)
        view.addSubview(confirmPasswordTextfield)
        view.addSubview(emailErrorLabel)
        view.addSubview(usernameErrorLabel)
        view.addSubview(passwordErrorLabel)
        view.addSubview(submitButton)
        view.addSubview(cancelButton)
        
        emailTextField.delegate = self
        usernameTextfield.delegate = self
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        let padding: CGFloat = 16
        
        welcomeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 50, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        emailTextField.anchor(top: welcomeLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 75, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 40, enableInsets: false)
        usernameTextfield.anchor(top: emailTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: padding * 1.5, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 40, enableInsets: false)
        passwordTextfield.anchor(top: usernameTextfield.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: padding * 3, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 40, enableInsets: false)
        confirmPasswordTextfield.anchor(top: passwordTextfield.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: padding, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 40, enableInsets: false)
        emailErrorLabel.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: emailTextField.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: padding, paddingBottom: 5, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        usernameErrorLabel.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: usernameTextfield.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: padding, paddingBottom: 5, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        passwordErrorLabel.anchor(top: confirmPasswordTextfield.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 0, enableInsets: false)
        submitButton.anchor(top: passwordErrorLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 50, enableInsets: false)
        cancelButton.anchor(top: submitButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: padding, paddingBottom: 0, paddingRight: padding, width: 0, height: 30, enableInsets: false)
    }
    
    @objc func didTapSignUp() {
        
        self.email = nil
        self.username = nil
        self.password = nil
        
        if emailTextField.text?.isEmpty ?? true {
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            emailTextField.layer.borderColor = UIColor.gray.cgColor
        }
        
        if usernameTextfield.text?.isEmpty ?? true {
            usernameTextfield.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            usernameTextfield.layer.borderColor = UIColor.gray.cgColor
        }
        
        if passwordTextfield.text?.isEmpty ?? true {
            passwordTextfield.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            passwordTextfield.layer.borderColor = UIColor.gray.cgColor
        }
        
        if confirmPasswordTextfield.text?.isEmpty ?? true {
            confirmPasswordTextfield.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            confirmPasswordTextfield.layer.borderColor = UIColor.gray.cgColor
        }
        
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextfield.text, !username.isEmpty,
              let password = passwordTextfield.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextfield.text, !confirmPassword.isEmpty else {
            return
        }
        
        if password != confirmPassword {
            passwordErrorLabel.isHidden = false
        } else {
            passwordErrorLabel.isHidden = true
            self.password = password
        }
        
        checkEmail(email: email)
        checkUsername(username: username)
    }
    
    private func checkEmail(email: String) {
        GroupSoundAPI.shared.emailAvailable(email) { [weak self] available in
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
    
    private func checkUsername(username: String) {
        GroupSoundAPI.shared.usernameAvailable(username) { [weak self] available in
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
    
    private func createUser() {
        
        guard let username = username, let email = email, let password = password, !userCreated else {
            return
        }
        
        userCreated = true
        
        GroupSoundAPI.shared.createUser(withEmail: email, withUsername: username, withPassword: password) { [weak self] user in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Account Created!", message: "CONGRATS! Your groupSound account has been created. Please sign in to access your account.", preferredStyle: .alert)
                let continueAction = UIAlertAction(title: "Return to Sign In", style: .default) { _ in
                    self?.returnToSignIn()
                }
                
                alert.addAction(continueAction)
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func returnToSignIn() {
        self.navigationController?.popViewController(animated: true)
    }

}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
           nextField.becomeFirstResponder()
        } else {
           textField.resignFirstResponder()
        }
          
        return false
    }
}
