//
//  WalletButtonView.swift
//  Buroku3
//
//  Created by J C on 2021-03-24.
//

import UIKit

class WalletButtonView: UIView {
    var image: UIImage!
    var labelName: String!
    var buttonAction: (()->Void)?
    var label: UILabel!
    var button: UIButton!
    var containerView = UIView()
    
    init(imageName: String, labelName: String) {
        super.init(frame: .zero)
        self.image = UIImage(systemName: imageName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.labelName = labelName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure()
        setConstraints()
    }
}

extension WalletButtonView {
    func configure() {
        containerView.backgroundColor = UIColor(red: 74/255, green: 71/255, blue: 163/255, alpha: 1)
        containerView.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        containerView.layer.cornerRadius = containerView.frame.size.width / 2
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        
        //add label and button
        button = UIButton.systemButton(with: image, target: self, action:  #selector(buttonTapped(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)
        
        label = UILabel()
        label.text = labelName
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 74/255, green: 71/255, blue: 163/255, alpha: 1)
        label.sizeToFit()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),
            containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor),
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            
            // button
            button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            button.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            
            // label
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.50),
            label.widthAnchor.constraint(equalTo: label.heightAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if let buttonAction = self.buttonAction {
            buttonAction()
        }
    }
}
