//
//  ReceiveViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-24.
//

import UIKit

class ReceiveViewController: UIViewController {
    var localDatabase: LocalDatabase!
    var wallet: KeyWalletModel!
    var address: String!
    var backgroundView: BackgroundView3!
    var closeButton: UIButton!
    var copyButton: WalletButtonView!
    var shareButton: WalletButtonView!
    var stackView: UIStackView!
    var qrCodeImageView: UIImageView!
    var addressLabel: EdgeInsetLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureWallet()
        configureUI()
        setConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalCount = 5
        let duration = 1.0 / Double(totalCount)
        
        let animation = UIViewPropertyAnimator(duration: 1, timingParameters: UICubicTimingParameters())
        animation.addAnimations {
            UIView.animateKeyframes(withDuration: 0, delay: 0, animations: { [weak self] in
                UIView.addKeyframe(withRelativeStartTime: 1 / Double(totalCount), relativeDuration: duration) {
                    self?.qrCodeImageView.alpha = 1
                    self?.qrCodeImageView.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 1 / Double(totalCount), relativeDuration: duration) {
                    self?.addressLabel.alpha = 1
                    self?.addressLabel.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 2 / Double(totalCount), relativeDuration: duration) {
                    self?.stackView.alpha = 1
                    self?.stackView.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 3 / Double(totalCount), relativeDuration: duration) {
                    self?.backgroundView.alpha = 1
                    self?.backgroundView.transform = .identity
                }
            })
        }
        
        animation.startAnimation()
    }
}

extension ReceiveViewController {
    func configureWallet() {
        localDatabase = LocalDatabase()
        wallet = localDatabase.getWallet()
        address = wallet.address
    }
    
    func configureUI() {
        view.backgroundColor = .white
        backgroundView = BackgroundView3()
        backgroundView.transform = CGAffineTransform(translationX: 0, y: 100)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.alpha = 0
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
        
        let qrCodeImage = generateQRCode(from: address)
        qrCodeImageView = UIImageView(image: qrCodeImage)
        let origin = CGPoint(x: view.frame.size.width / 2 - 100, y: view.frame.size.height / 2 - 300)
        qrCodeImageView.frame = CGRect(origin: origin, size: CGSize(width: 200, height: 200))
        qrCodeImageView.transform = CGAffineTransform(translationX: 0, y: 100)
        qrCodeImageView.alpha = 0
        view.addSubview(qrCodeImageView)
        
        addressLabel = EdgeInsetLabel()
        addressLabel.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        BorderStyle.customShadowBorder(for: addressLabel)
        addressLabel.numberOfLines = 0
        addressLabel.alpha = 0
        addressLabel.transform = CGAffineTransform(translationX: 0, y: 100)
        addressLabel.text = address
        addressLabel.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addressLabel)
        
        copyButton = WalletButtonView(imageName: "square.on.square", labelName: "Copy")
        copyButton.buttonAction = { [weak self] in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self?.address ?? ""
            print("copied")
        }
        shareButton = WalletButtonView(imageName: "square.and.arrow.up", labelName: "Share")
        stackView = UIStackView(arrangedSubviews: [copyButton, shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
//        stackView.spacing = 150
        stackView.transform = CGAffineTransform(translationX: 0, y: 100)
        stackView.alpha = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // close button
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 60),
            
            // background view
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 3/5),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // address label
            addressLabel.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 50),
            addressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addressLabel.widthAnchor.constraint(equalToConstant: 200),
            addressLabel.heightAnchor.constraint(equalToConstant: 90),
            
            // copy button
            copyButton.heightAnchor.constraint(equalToConstant: 100),
            
            // stack view
            stackView.widthAnchor.constraint(equalToConstant: 260),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 50),
            stackView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 1, y: 1)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        switch sender.tag {
            case 1:
                self.dismiss(animated: true, completion: nil)
            case 2:
                break
            default:
                break
        }
    }
}


class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
