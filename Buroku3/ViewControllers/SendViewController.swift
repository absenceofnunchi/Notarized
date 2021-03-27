//
//  SendViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-25.
//

import UIKit
import web3swift

class SendViewController: UIViewController {
    var closeButton: UIButton!
    var destinationLabel: UILabel!
    var destinationTextField: UITextField!
    var amountLabel: UILabel!
    var amountTextField: UITextField!
    var scanButton: UIButton!
    var sendButton: UIButton!
    var gasPriceLabel: UILabel!
    var maxButton: UIButton!
    var backgroundView: BackgroundView5!
    
    let transactionService = TransactionService()
    let localDatabase = LocalDatabase()
    let alert = Alerts()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalCount = 6
        let duration = 1.0 / Double(totalCount)
        
        let animation = UIViewPropertyAnimator(duration: 0.7, timingParameters: UICubicTimingParameters())
        animation.addAnimations {
            UIView.animateKeyframes(withDuration: 0, delay: 0, animations: { [weak self] in
                UIView.addKeyframe(withRelativeStartTime: 1 / Double(totalCount), relativeDuration: duration) {
                    self?.destinationLabel.alpha = 1
                    self?.destinationLabel.transform = .identity
                    
                    self?.destinationTextField.alpha = 1
                    self?.destinationTextField.transform = .identity
                    
                    self?.scanButton.alpha = 1
                    self?.scanButton.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 2 / Double(totalCount), relativeDuration: duration) {
                    self?.amountLabel.alpha = 1
                    self?.amountLabel.transform = .identity
                    
                    self?.amountTextField.alpha = 1
                    self?.amountTextField.transform = .identity
                    
                    self?.maxButton.alpha = 1
                    self?.maxButton.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 3 / Double(totalCount), relativeDuration: duration) {
                    self?.sendButton.alpha = 1
                    self?.sendButton.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 4 / Double(totalCount), relativeDuration: duration) {
                    self?.gasPriceLabel.alpha = 1
                    self?.gasPriceLabel.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 5 / Double(totalCount), relativeDuration: duration) {
                    self?.backgroundView.alpha = 1
                    self?.backgroundView.transform = .identity
                }
            })
        }
        
        animation.startAnimation()
    }
}

extension SendViewController {
    
    // MARK: - configureUI
    func configureUI() {
        view.backgroundColor = .white
        
        backgroundView = BackgroundView5()
        backgroundView.transform = CGAffineTransform(translationX: 0, y: 40)
        backgroundView.alpha = 0
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.setNeedsDisplay()
        view.addSubview(backgroundView)
        
        // close button
        guard let closeButtonImage = UIImage(systemName: "multiply") else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        closeButton = UIButton.systemButton(with: closeButtonImage, target: self, action: #selector(buttonHandler))
        closeButton.tag = 1
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .black
        view.addSubview(closeButton)

        destinationLabel = createTitleLabel(title: "To", v: self.view)
        destinationLabel.transform = CGAffineTransform(translationX: 0, y: 40)
        destinationLabel.alpha = 0
        
        destinationTextField = UITextField()
        destinationTextField.transform = CGAffineTransform(translationX: 0, y: 40)
        destinationTextField.alpha = 0
        destinationTextField.textColor = .darkGray
        destinationTextField.placeholder = "public address (0x)"
        destinationTextField.setLeftPaddingPoints(10)
        BorderStyle.customShadowBorder(for: destinationTextField)
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(destinationTextField)
        
        guard let scanButtonImage = UIImage(systemName: "barcode.viewfinder") else { return }
        scanButton = UIButton.systemButton(with: scanButtonImage.withTintColor(.white, renderingMode: .alwaysOriginal), target: self, action: #selector(buttonHandler(_:)))
        scanButton.backgroundColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
        scanButton.transform = CGAffineTransform(translationX: 0, y: 40)
        scanButton.layer.cornerRadius = 7
        scanButton.alpha = 0
        scanButton.tag = 2
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanButton)
        
        amountLabel = createTitleLabel(title: "Amount", v: self.view)
        amountLabel.transform = CGAffineTransform(translationX: 0, y: 40)
        amountLabel.alpha = 0
        
        amountTextField = UITextField()
        amountTextField.transform = CGAffineTransform(translationX: 0, y: 40)
        amountTextField.alpha = 0
        amountTextField.textColor = .darkGray
        amountTextField.placeholder = "ETH"
        amountTextField.setLeftPaddingPoints(10)
        amountTextField.keyboardType = UIKeyboardType.decimalPad
        BorderStyle.customShadowBorder(for: amountTextField)
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountTextField)
        
        maxButton = UIButton()
        maxButton.setTitle("MAX", for: .normal)
        maxButton.addTarget(self, action: #selector(buttonHandler(_:)), for: .touchUpInside)
        maxButton.translatesAutoresizingMaskIntoConstraints = false
        maxButton.tag = 3
        maxButton.alpha = 0
        maxButton.layer.cornerRadius = 7
        maxButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        maxButton.transform = CGAffineTransform(translationX: 0, y: 40)
        maxButton.backgroundColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
        view.addSubview(maxButton)
        
        sendButton = UIButton()
        sendButton.transform = CGAffineTransform(translationX: 0, y: 40)
        sendButton.alpha = 0
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(buttonHandler(_:)), for: .touchUpInside)
        sendButton.tag = 4
        sendButton.backgroundColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
        sendButton.layer.cornerRadius = 7
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        gasPriceLabel = UILabel()
        gasPriceLabel.sizeToFit()
        gasPriceLabel.transform = CGAffineTransform(translationX: 0, y: 40)
        gasPriceLabel.alpha = 0
        gasPriceLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        gasPriceLabel.textColor = .gray
        gasPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gasPriceLabel)
        transactionService.requestGasPrice { (gasPrice) in
            guard let gasPrice = gasPrice else { return }
            self.gasPriceLabel.text = "Current avg. gas price: \(gasPrice) GWEI"
        }
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        NSLayoutConstraint.activate([
            // background view
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2),
            
            // close button
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 60),
            
            // destination label
            destinationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            destinationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            destinationLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            
            // destination text field
            destinationTextField.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 20),
            destinationTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            destinationTextField.heightAnchor.constraint(equalToConstant: 50),
            destinationTextField.trailingAnchor.constraint(equalTo: scanButton.leadingAnchor, constant: -10),
            
            // scan button
            scanButton.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 20),
            scanButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            scanButton.widthAnchor.constraint(equalTo: scanButton.heightAnchor, multiplier: 1),
            
            // amount label
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountLabel.topAnchor.constraint(equalTo: destinationTextField.bottomAnchor, constant: 40),
            amountLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            
            // amount text field
            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            amountTextField.heightAnchor.constraint(equalToConstant: 50),
            amountTextField.trailingAnchor.constraint(equalTo: maxButton.leadingAnchor, constant: -10),
            
            // max button
            maxButton.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            maxButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            maxButton.heightAnchor.constraint(equalToConstant: 50),
            maxButton.widthAnchor.constraint(equalTo: maxButton.heightAnchor, multiplier: 1),
            
            // send button
            sendButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 50),
            sendButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            sendButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            
            // gas price label
            gasPriceLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 10),
            gasPriceLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            gasPriceLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    

    // MARK: - createTitleLabel
    func createTitleLabel(title: String, v: UIView) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        return label
    }
}

extension SendViewController: UITextFieldDelegate {
    // MARK: - buttonHandler
    @objc func buttonHandler(_ sender: UIButton) {
        
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        switch sender.tag {
            case 1:
                self.dismiss(animated: true, completion: nil)
            case 2:
                let scannerVC = ScannerViewController()
                scannerVC.delegate = self
                scannerVC.modalPresentationStyle = .fullScreen
                self.present(scannerVC, animated: true, completion: nil)
            case 3:
                guard let address = Web3swiftService.currentAddress else {
                    print("invalid address")
                    return
                }
                
                DispatchQueue.global().async {
                    do {
                        let balance = try Web3swiftService.web3instance.eth.getBalance(address: address)
                        if let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 4) {
                            DispatchQueue.main.async {
                                self.amountTextField.text = self.transactionService.stripZeros(balanceString)
                            }
                        }
                    } catch {
                        print("get balance error", error.localizedDescription)
                    }
                }
            case 4:
                transactionService.prepareTransactionForSending(destinationAddressString: destinationTextField.text, amountString: amountTextField.text) { (transaction, error) in
                    if let error = error {
                        switch error {
                            case .invalidDestinationAddress:
                                self.alert.show("Error", with: "Invalid destination address", for: self)
                            case .invalidAmountFormat:
                                self.alert.show("Error", with: "Invalid amount format", for: self)
                            case .emptyDestinationAddress:
                                self.alert.show("Error", with: "Destination address cannot be empty", for: self)
                            case .emptyAmount:
                                self.alert.show("Error", with: "Amount cannot be empty", for: self)
                            case .zeroAmount:
                                self.alert.show("Error", with: "Amount cannot be zero or below", for: self)
                            case .contractLoadingError:
                                self.alert.show("Error", with: "There was an error loading a contract. Please try again.", for: self)
                            case .createTransactionIssue:
                                self.alert.show("Error", with: "There was an error creating your transaction. Please try again.", for: self)
                            case .insufficientFund:
                                self.alert.show("Error", with: "Insufficient fund", for: self)
                            default:
                                self.alert.show("Error", with: "Please try again.", for: self)
                        }
                    }
                    
                    if let transaction = transaction {
                        let ac = UIAlertController(title: "Enter the password", message: nil, preferredStyle: .alert)
                        ac.addTextField { (textField: UITextField!) in
                            textField.delegate = self
                        }
                        
                        let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac, weak self](_) in
                            guard let textField = ac.textFields?.first, let password = textField.text else { return }
                            DispatchQueue.global().async {
                                do {
                                    let result = try transaction.send(password: password, transactionOptions: nil)
                                    
                                    let tran = result.transaction

                                    let txModel = TxModel(gasPrice: tran.gasPrice.description, gasLimit: tran.gasLimit.description, toAddress: tran.to.address, value: tran.value!.description, date: Date(), nonce: tran.nonce.description)
                                    
                                    self?.localDatabase.saveTransactionDetail(result: txModel) { (error) in
                                        if let error = error {
                                            print("error save tx", error)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            let finalAC = UIAlertController(title: "Success!", message: "Your ether has been sent.", preferredStyle: .alert)
                                            finalAC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                                self?.dismiss(animated: true, completion: nil)
                                            }))
                                            self?.present(finalAC, animated: true, completion: nil)
                                        }
                                    }
//                                    print("Int64(gpStr )", Int64(gpStr ?? ""))
//                                    print("hashString", String(data: hashData, encoding: .utf8))
//                                    if let gpInt = Int64(gpStr ?? ""), let glInt = Int64(glStr ?? ""), let valueInt = Int64(valueStr ?? ""), let nonceInt = Int64(nonceStr ?? ""), let hashString = String(data: hashData, encoding: .utf8) {
//                                        let txModel = TxModel(gasPrice: gpInt, gasLimit: glInt, toAddress: tran.to.address, value: valueInt, date: Date().description(with: .current), hashString: hashString, nonce: nonceInt)
//
//                                        self?.localDatabase.saveTransactionDetail(result: txModel) { (error) in
//                                            if let error = error {
//                                                print("error save tx", error)
//                                            }
//
//                                            DispatchQueue.main.async {
//                                                let finalAC = UIAlertController(title: "Success!", message: "Your ether has been sent.", preferredStyle: .alert)
//                                                finalAC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
//                                                    self?.dismiss(animated: true, completion: nil)
//                                                }))
//                                                self?.present(finalAC, animated: true, completion: nil)
//                                            }
//                                        }
//                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        self?.alert.show("Error", with: "Sorry, there was an error sending your ether. Please try again.", for: self!)
                                    }
                                }
                            }
                        }
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                        
                        ac.addAction(enterAction)
                        ac.addAction(cancelAction)
                        self.present(ac, animated: true, completion: nil)
                    }
                }
            default:
                break
        }
    }
    
}

extension SendViewController: ScannerDelegate {
    
    // MARK: - scannerDidOutput
    func scannerDidOutput(code: String) {
        destinationTextField.text = code
    }
}


