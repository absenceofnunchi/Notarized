//
//  ImportViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-26.
//

import UIKit
import Lottie

class ImportWalletViewController: UIViewController {
    var closeButton: UIButton!
    var importButton: UIButton!
    var containerView: BlurEffectContainerView!
    var backgroundView: BackgroundView6!
    var enterPrivateKeyTextField: UITextField!
    var passwordTextField: UITextField!
    var textFields = [UITextField]()
    let animationView = AnimationView()
    var warningLabel: UILabel!

    weak var delegate: WalletDelegate?
    let keyService = KeysService()
    let localDatabase = LocalDatabase()
    let alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureLogoAnimation()
        configureNavigationItem()
        setConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalCount = 4
        let duration = 1.0 / Double(totalCount)
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, animations: {
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
        
//        if isWalletCreated {
//            delegate?.didProcessWallet()
//        }
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.backgroundView.transform = CGAffineTransform(translationX: 0, y: 80)
                self.backgroundView.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: 80)
                self.containerView.alpha = 0
            }
        },
        completion: nil
        )
    }
}

extension ImportWalletViewController {
    func configureNavigationItem() {
        let navBar = self.navigationController?.navigationBar
        navBar?.tintColor = .gray
    }
    
    // MARK: - configureLogoAnimation
    func configureLogoAnimation() {
        // animation
        animationView.animation = Animation.named("6")
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.alpha = 0
        animationView.transform = CGAffineTransform(translationX: 0, y: 80)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        //        let keypath = AnimationKeypath(keys: ["**", "Fill", "**", "Color"])
        let keypath = AnimationKeypath(keypath: "**.**.**.Color")
        let colorProvider = ColorValueProvider(UIColor.black.lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
        view.addSubview(animationView)
        animationView.play()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        self.hideKeyboardWhenTappedAround()

        // background
        backgroundView = BackgroundView6()
        backgroundView.alpha = 0
        backgroundView.transform = CGAffineTransform(translationX: 0, y: 80)
        view.addSubview(backgroundView)
        backgroundView.fill()
        
        guard let image = UIImage(systemName: "multiply") else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // close button
        closeButton = UIButton.systemButton(with: image, target: self, action: #selector(buttonHandler))
        closeButton.tag = 1
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .black
        view.addSubview(closeButton)
        
        // warning label
        warningLabel = UILabel()
        warningLabel.sizeToFit()
        warningLabel.isHidden = true
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(warningLabel)
        
        // container view
        containerView = BlurEffectContainerView()
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 80)
        containerView.layer.zPosition = 100
        view.addSubview(containerView)
        
        // repeat password text field
        passwordTextField = UITextField()
        passwordTextField.delegate = self
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.placeholder = "Enter your password"
        textFields.append(passwordTextField)
        passwordTextField.setLeftPaddingPoints(10)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(passwordTextField)
        
        // enter private key
        enterPrivateKeyTextField = UITextField()
        enterPrivateKeyTextField.delegate = self
        enterPrivateKeyTextField.layer.borderWidth = 1
        enterPrivateKeyTextField.layer.cornerRadius = 10
        enterPrivateKeyTextField.placeholder = "Enter your private key"
        enterPrivateKeyTextField.layer.borderColor = UIColor.lightGray.cgColor
        enterPrivateKeyTextField.setLeftPaddingPoints(10)
        textFields.append(enterPrivateKeyTextField)
        enterPrivateKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(enterPrivateKeyTextField)
        
        // create wallet button
        importButton = UIButton()
        importButton.setTitle("Import Wallet", for: .normal)
        importButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        importButton.tag = 2
        importButton.backgroundColor = .black
        importButton.layer.cornerRadius = 10
        importButton.isEnabled = false
        importButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(importButton)
    }
    
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
            
            // warning label
            warningLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // animation view
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.heightAnchor.constraint(equalToConstant: 200),
            animationView.widthAnchor.constraint(equalTo: animationView.heightAnchor),
            
            // password text field
            passwordTextField.bottomAnchor.constraint(equalTo: enterPrivateKeyTextField.topAnchor, constant: -50),
            passwordTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // enterPrivateKeyTextField text field
            enterPrivateKeyTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            enterPrivateKeyTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            enterPrivateKeyTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            enterPrivateKeyTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // import wallet button
            importButton.topAnchor.constraint(equalTo: enterPrivateKeyTextField.bottomAnchor, constant: 50),
            importButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            importButton.heightAnchor.constraint(equalToConstant: 50),
            importButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        switch sender.tag {
            case 1:
                self.dismiss(animated: true, completion: nil)
            case 2:
                importWallet()
            default:
                break
        }
    }
}

extension ImportWalletViewController: UITextFieldDelegate {
    // MARK: - textFieldDidBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = importButton.isEnabled ? UIReturnKeyType.done : .next
//        textField.textColor = UIColor.orange
    }
    
    // MARK: - textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String
        importButton.isEnabled = false
        
        switch textField {
            case passwordTextField:
                if !futureString.isEmpty {
                    warningLabel.isHidden = true
                    importButton.isEnabled = !(enterPrivateKeyTextField.text?.isEmpty ?? true)
                } else {
                    warningLabel.isHidden = false
                    importButton.isEnabled = false
                }
            case enterPrivateKeyTextField:
                if  !futureString.isEmpty {
                    importButton.isEnabled = !(passwordTextField.text?.isEmpty ?? true)
                } else {
                    warningLabel.isHidden = false
                    importButton.isEnabled = false
                }
            default:
                importButton.isEnabled = false
                warningLabel.isHidden = false
        }
        
        importButton.alpha = importButton.isEnabled ? 1.0 : 0.5
        textField.returnKeyType = importButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
    
    // MARK: - textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && importButton.isEnabled {
            importWallet()
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

extension ImportWalletViewController {
    func importWallet() {
        guard let password = passwordTextField.text, let privateKey = enterPrivateKeyTextField.text else { return }
        keyService.addNewWalletWithPrivateKey(key: privateKey, password: password) { [weak self](wallet, error) in
            if let error = error {
                print("addNewWallet error", error)
                DispatchQueue.main.async {
                    self?.alert.show("Error", with: "There was an error importing your wallet", for: self!)
                }
                return
            }
            
            guard let wallet = wallet else { return }
            self?.localDatabase.saveWallet(isRegistered: true, wallet: wallet) { [weak self](error) in
                if let _ = error {
                    DispatchQueue.main.async {
                        self?.alert.show("Error", with: "There was an error saving your imported wallet", for: self!)
                    }
                    return
                }
                
                
                self?.delegate?.didProcessWallet()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
