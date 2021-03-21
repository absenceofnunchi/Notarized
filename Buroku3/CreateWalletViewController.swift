//
//  CreateWalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import UIKit

class CreateWalletViewController: UIViewController {
    var mode: WalletCreationType = .createKey
    let keysService: KeysService = KeysService()
    let localStorage = LocalDatabase()
    let web3service: Web3swiftService = Web3swiftService()
    let alerts = Alerts()
    let walletController = WalletGenerationController()
    
    var passwordTextField: UITextField!
    var repeatPasswordTextField: UITextField!
    var createButton: UIButton!
    var passwordsDontMatch: UILabel!
    var enterPrivateKeyTextField: UITextField!
    var textFields = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
        self.hideKeyboardWhenTappedAround()
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        enterPrivateKeyTextField.delegate = self
        view.backgroundColor = .white
    }
}

extension CreateWalletViewController {
    
    // MARK: - ConfigureUI
    
    func configureUI() {
        // passwords don't match label
        passwordsDontMatch = UILabel()
        passwordsDontMatch.translatesAutoresizingMaskIntoConstraints = false
        passwordsDontMatch.isHidden = true
        view.addSubview(passwordsDontMatch)
        
        // password text field
        passwordTextField = UITextField()
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        textFields.append(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // repeat password text field
        repeatPasswordTextField = UITextField()
        repeatPasswordTextField.borderStyle = .roundedRect
        repeatPasswordTextField.layer.borderWidth = 1
        repeatPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        textFields.append(repeatPasswordTextField)
        repeatPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(repeatPasswordTextField)
        
        // enter private key
        enterPrivateKeyTextField = UITextField()
        enterPrivateKeyTextField.borderStyle = .roundedRect
        enterPrivateKeyTextField.layer.borderWidth = 1
        enterPrivateKeyTextField.layer.borderColor = UIColor.lightGray.cgColor
        enterPrivateKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enterPrivateKeyTextField)
        enterPrivateKeyTextField.isHidden = true
        
        // create wallet button
        createButton = UIButton()
        createButton.setTitle("Create Wallet", for: .normal)
        createButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        createButton.backgroundColor = .black
        createButton.layer.cornerRadius = 20
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
    }
    
    // MARK: - SetConstraints
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            passwordsDontMatch.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            passwordsDontMatch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordsDontMatch.widthAnchor.constraint(equalToConstant: 100),
            passwordsDontMatch.heightAnchor.constraint(equalToConstant: 50),
            
            // password text field
            passwordTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // repeat password text field
            repeatPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 50),
            repeatPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            repeatPasswordTextField.widthAnchor.constraint(equalToConstant: 200),
            repeatPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // create wallet button
            createButton.topAnchor.constraint(equalTo: repeatPasswordTextField.bottomAnchor, constant: 50),
            createButton.widthAnchor.constraint(equalToConstant: 200),
            createButton.heightAnchor.constraint(equalToConstant: 100),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Button Handler
    
    @objc func buttonHandler() {
        createWallet()
    }
    
    // MARK: - Create Wallet
    
    func createWallet() {
        guard passwordTextField.text == repeatPasswordTextField.text else {
            passwordsDontMatch.isHidden = false
            return
        }
        
        passwordsDontMatch.isHidden = true
        
        walletController.createWallet(with: mode, password: passwordTextField.text, key: enterPrivateKeyTextField.text) { (error) in
            guard error == nil else {
                self.alerts.show(error, for: self)
                return
            }
            
            print("wallet created")
        }
    }
}

extension CreateWalletViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = createButton.isEnabled ? UIReturnKeyType.done : .next
        textField.textColor = UIColor.orange
        if textField == passwordTextField || textField == repeatPasswordTextField {
            passwordsDontMatch.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        createButton.isEnabled = false
        
        switch textField {
            case enterPrivateKeyTextField:
                if passwordTextField.text == repeatPasswordTextField.text &&
                    !(passwordTextField.text?.isEmpty ?? true) &&
                    !futureString.isEmpty && ((passwordTextField.text?.count)! > 4) {
                    createButton.isEnabled = true
                }
            case passwordTextField:
                if !futureString.isEmpty &&
                    futureString == repeatPasswordTextField.text ||
                    repeatPasswordTextField.text?.isEmpty == true {
                    passwordsDontMatch.isHidden = true
                    createButton.isEnabled = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || mode == .createKey)
                } else {
                    passwordsDontMatch.isHidden = false
                    createButton.isEnabled = false
                }
            case repeatPasswordTextField:
                if !futureString.isEmpty &&
                    futureString == passwordTextField.text {
                    passwordsDontMatch.isHidden = true
                    createButton.isEnabled = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || mode == .createKey)
                } else {
                    passwordsDontMatch.isHidden = false
                    createButton.isEnabled = false
                }
            default:
                createButton.isEnabled = false
                passwordsDontMatch.isHidden = false
        }
        
        createButton.alpha = createButton.isEnabled ? 1.0 : 0.5
        textField.returnKeyType = createButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.textColor = UIColor.darkGray
        
        guard textField == repeatPasswordTextField ||
                textField == passwordTextField else {
            return true
        }
        if (!(passwordTextField.text?.isEmpty ?? true) ||
                !(repeatPasswordTextField.text?.isEmpty ?? true)) &&
            passwordTextField.text != repeatPasswordTextField.text {
            passwordsDontMatch.isHidden = false
            passwordsDontMatch.text = "Passwords don't match"
            repeatPasswordTextField.textColor = UIColor.red
            passwordTextField.textColor = UIColor.red
        } else if (!(passwordTextField.text?.isEmpty ?? true) ||
                    !(repeatPasswordTextField.text?.isEmpty ?? true)) &&
                    ((passwordTextField.text?.count)! < 5) {
            passwordsDontMatch.isHidden = false
            passwordsDontMatch.text = "Password is too short"
            repeatPasswordTextField.textColor = UIColor.red
            passwordTextField.textColor = UIColor.red
        } else {
            repeatPasswordTextField.textColor = UIColor.darkGray
            passwordTextField.textColor = UIColor.darkGray
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && createButton.isEnabled && ((passwordTextField.text?.count)! > 4) {
            createWallet()
        } else if textField.returnKeyType == .next {
            let index = textFields.firstIndex(of: textField) ?? 0
            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
            textFields[nextIndex].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}
