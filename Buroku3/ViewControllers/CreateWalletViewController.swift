//
//  CreateWalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import UIKit
import Lottie

class CreateWalletViewController: UIViewController {
    var mode: WalletCreationType = .createKey
    let keysService: KeysService = KeysService()
    let localStorage = LocalDatabase()
    let web3service: Web3swiftService = Web3swiftService()
    let alerts = Alerts()
    let walletController = WalletGenerationController()
    weak var delegate: WalletDelegate?
    var isWalletCreated = false
    
    let animationView = AnimationView()
    var passwordTextField: UITextField!
    var repeatPasswordTextField: UITextField!
    var createButton: UIButton!
    var passwordsDontMatch: UILabel!
    var textFields = [UITextField]()
    var closeButton: UIButton!
    var containerView: BlurEffectContainerView!
    var backgroundView: BackgroundView3!
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLogoAnimation()
        configureUI()
        setConstraints()
        self.hideKeyboardWhenTappedAround()
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalCount = 4
        let duration = 1.0 / Double(totalCount)
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 1 / Double(totalCount), relativeDuration: duration) {
                self.animationView.alpha = 1
                self.animationView.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 2 / Double(totalCount), relativeDuration: duration) {
                self.containerView.alpha = 1
                self.containerView.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 3 / Double(totalCount), relativeDuration: duration) {
                self.backgroundView.alpha = 1
                self.backgroundView.transform = .identity
            }
        },
        completion: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isWalletCreated {
            delegate?.didProcessWallet()
        }
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                    self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 80)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: 80)
                }
            },
            completion: nil
        )
    }
}

extension CreateWalletViewController {
    
    // MARK: - configureLogoAnimation
    func configureLogoAnimation() {
        // animation
        animationView.animation = Animation.named("6")
        animationView.alpha = 0
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.transform = CGAffineTransform(translationX: 0, y: 80)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        //        let keypath = AnimationKeypath(keys: ["**", "Fill", "**", "Color"])
        let keypath = AnimationKeypath(keypath: "**.**.**.Color")
        let colorProvider = ColorValueProvider(UIColor.black.lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
        view.addSubview(animationView)
        animationView.play()
    }
    
    // MARK: - ConfigureUI
    func configureUI() {
        view.backgroundColor = .white
        guard let image = UIImage(systemName: "multiply") else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // background
        backgroundView = BackgroundView3()
        backgroundView.alpha = 0
        backgroundView.transform = CGAffineTransform(translationX: 0, y: 80)
        view.addSubview(backgroundView)
        backgroundView.fill()
        
        // close button
        closeButton = UIButton.systemButton(with: image, target: self, action: #selector(buttonHandler))
        closeButton.tag = 1
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .black
        view.addSubview(closeButton)
        
        // container view
        containerView = BlurEffectContainerView()
        containerView.transform = CGAffineTransform(translationX: 0, y: 80)
        containerView.alpha = 0
        view.addSubview(containerView)
        
        // passwords don't match label
        passwordsDontMatch = UILabel()
        passwordsDontMatch.translatesAutoresizingMaskIntoConstraints = false
        passwordsDontMatch.isHidden = true
        view.addSubview(passwordsDontMatch)
        
        // password text field
        passwordTextField = UITextField()
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.placeholder = "Create a new password"
        textFields.append(passwordTextField)
        passwordTextField.setLeftPaddingPoints(10)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(passwordTextField)
        
        // repeat password text field
        repeatPasswordTextField = UITextField()
        repeatPasswordTextField.layer.borderWidth = 1
        repeatPasswordTextField.layer.borderColor = UIColor.gray.cgColor
        repeatPasswordTextField.layer.cornerRadius = 10
        repeatPasswordTextField.placeholder = "Enter your password again"
        textFields.append(repeatPasswordTextField)
        repeatPasswordTextField.setLeftPaddingPoints(10)
        repeatPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(repeatPasswordTextField)
        
        // create wallet button
        createButton = UIButton()
        createButton.setTitle("Create Wallet", for: .normal)
        createButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        createButton.tag = 2
        createButton.backgroundColor = .black
        createButton.layer.cornerRadius = 10
        createButton.isEnabled = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(createButton)
    }
    
    // MARK: - SetConstraints
    
    func setConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                // container view
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                containerView.heightAnchor.constraint(equalToConstant: 350),
            ])
        }else{
            NSLayoutConstraint.activate([
                // container view
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.2),
            ])
        }
        
        NSLayoutConstraint.activate([
            // close button
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 60),
            
            // animation view
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.heightAnchor.constraint(equalToConstant: 200),
            animationView.widthAnchor.constraint(equalTo: animationView.heightAnchor),
            
            // paswords don't match label
            passwordsDontMatch.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            passwordsDontMatch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordsDontMatch.widthAnchor.constraint(equalToConstant: 100),
            passwordsDontMatch.heightAnchor.constraint(equalToConstant: 50),
            
            // password text field
            passwordTextField.bottomAnchor.constraint(equalTo: repeatPasswordTextField.topAnchor, constant: -50),
            passwordTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // repeat password text field
            repeatPasswordTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            repeatPasswordTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            repeatPasswordTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            repeatPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // create wallet button
            createButton.topAnchor.constraint(equalTo: repeatPasswordTextField.bottomAnchor, constant: 50),
            createButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
    }
    
    // MARK: - Button Handler
    
    @objc func buttonHandler(_ sender: UIButton!) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        switch sender.tag {
            case 1:
                self.dismiss(animated: true, completion: nil)
            case 2:
                createWallet()
            default:
                break
        }
    }
    
    // MARK: - Create Wallet
    
    func createWallet() {
        guard passwordTextField.text == repeatPasswordTextField.text else {
            passwordsDontMatch.isHidden = false
            return
        }
        
        passwordsDontMatch.isHidden = true
        
        walletController.createWallet(with: mode, password: passwordTextField.text, key: nil) { (error) in
            guard error == nil else {
                self.alerts.show(error, for: self)
                return
            }
            
            self.isWalletCreated = true
            self.dismiss(animated: true, completion: nil)
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
//            case enterPrivateKeyTextField:
//                if passwordTextField.text == repeatPasswordTextField.text &&
//                    !(passwordTextField.text?.isEmpty ?? true) &&
//                    !futureString.isEmpty && ((passwordTextField.text?.count)! > 4) {
//                    createButton.isEnabled = true
//                }
            case passwordTextField:
                if !futureString.isEmpty &&
                    futureString == repeatPasswordTextField.text ||
                    repeatPasswordTextField.text?.isEmpty == true {
                    passwordsDontMatch.isHidden = true
                    createButton.isEnabled = (mode == .createKey)
//                    createButton.isEnabled = (!(enterPrivateKeyTextField.text?.isEmpty ?? true) || mode == .createKey)
                } else {
                    passwordsDontMatch.isHidden = false
                    createButton.isEnabled = false
                }
            case repeatPasswordTextField:
                if !futureString.isEmpty &&
                    futureString == passwordTextField.text {
                    passwordsDontMatch.isHidden = true
                    createButton.isEnabled = (mode == .createKey)
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

