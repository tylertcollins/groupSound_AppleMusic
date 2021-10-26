//
//  Extensions.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/20/21.
//

import Foundation
import UIKit

extension UIView {
    
    func anchor (top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat, enableInsets: Bool) {
            var topInset = CGFloat(0)
            var bottomInset = CGFloat(0)
            
            if #available(iOS 11, *), enableInsets {
                let insets = self.safeAreaInsets
                topInset = insets.top
                bottomInset = insets.bottom
                
                print("Top: \(topInset)")
                print("bottom: \(bottomInset)")
            }
            
            translatesAutoresizingMaskIntoConstraints = false
            
            if let top = top {
                self.topAnchor.constraint(equalTo: top, constant: paddingTop+topInset).isActive = true
            }
            if let left = left {
                self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
            }
            if let right = right {
                rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
            }
            if let bottom = bottom {
                bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom-bottomInset).isActive = true
            }
            if height != 0 {
                heightAnchor.constraint(equalToConstant: height).isActive = true
            }
            if width != 0 {
                widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            
        }
    
    func anchor(centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?, top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat, enableInsets: Bool) {
        
        anchor(top: top, left: left, bottom: bottom, right: right, paddingTop: paddingTop, paddingLeft: paddingLeft, paddingBottom: paddingBottom, paddingRight: paddingRight, width: width, height: height, enableInsets: enableInsets)
        
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addKeyboardObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotifications(notification:)),
                                                   name: UIResponder.keyboardWillChangeFrameNotification,
                                                   object: nil)
        }

        func removeKeyboardObserver(){
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }

        // This method will notify when keyboard appears/ dissapears
        @objc func keyboardNotifications(notification: NSNotification) {

            var txtFieldY : CGFloat = 0.0  //Using this we will calculate the selected textFields Y Position
            let spaceBetweenTxtFieldAndKeyboard : CGFloat = 5.0 //Specify the space between textfield and keyboard


            var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            if let activeTextField = UIResponder.currentFirst() as? UITextField ?? UIResponder.currentFirst() as? UITextView {
                // Here we will get accurate frame of textField which is selected if there are multiple textfields
                frame = self.view.convert(activeTextField.frame, from:activeTextField.superview)
                txtFieldY = frame.origin.y + frame.size.height
            }

            if let userInfo = notification.userInfo {
                // here we will get frame of keyBoard (i.e. x, y, width, height)
                let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let keyBoardFrameY = keyBoardFrame!.origin.y
                let keyBoardFrameHeight = keyBoardFrame!.size.height

                var viewOriginY: CGFloat = 0.0
                //Check keyboards Y position and according to that move view up and down
                if keyBoardFrameY >= UIScreen.main.bounds.size.height {
                    viewOriginY = 0.0
                } else {
                    // if textfields y is greater than keyboards y then only move View to up
                    if txtFieldY >= keyBoardFrameY {

                        viewOriginY = (txtFieldY - keyBoardFrameY) + spaceBetweenTxtFieldAndKeyboard

                        //This condition is just to check viewOriginY should not be greator than keyboard height
                        // if its more than keyboard height then there will be black space on the top of keyboard.
                        if viewOriginY > keyBoardFrameHeight { viewOriginY = keyBoardFrameHeight }
                    }
                }

                //set the Y position of view
                self.view.frame.origin.y = -viewOriginY
            }
        }
}

extension UITextField {
    
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setPaddingPoints(left leftAmount: CGFloat, right rightAmount: CGFloat) {
        setLeftPaddingPoints(leftAmount)
        setRightPaddingPoints(rightAmount)
    }
}

extension UIColor {
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return nil
        }
    }
}

extension Date {
    func toSQLDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

extension UIResponder {

    static weak var responder: UIResponder?

    static func currentFirst() -> UIResponder? {
        responder = nil
        UIApplication.shared.sendAction(#selector(trap), to: nil, from: nil, for: nil)
        return responder
    }

    @objc private func trap() {
        UIResponder.responder = self
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String) {
        guard let url = URL(string: link.replacingOccurrences(of: "{w}", with: "\(frame.width)").replacingOccurrences(of: "{h}", with: "\(frame.height)")) else { return }
        downloaded(from: url)
    }
}
