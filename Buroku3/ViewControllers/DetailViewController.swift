//
//  DetailViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-21.
//

import UIKit

class DetailViewController: UIViewController {
    var titleString: String?
    var message: String?
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    var height: CGFloat!
    var buttonAction: ((UIViewController)->Void)?
    
    private lazy var customTransitioningDelegate = TransitioningDelegate(height: height)
    
    init(height: CGFloat = 300) {
        super.init(nibName: nil, bundle: nil)
        self.height = height
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("fatal error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
    }
}

private extension DetailViewController {
    func configure() {
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = customTransitioningDelegate
    }
    
    func configureUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
        titleLabel.text = titleString
        titleLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        

        messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tap)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func tapped() {
        if let buttonAction = self.buttonAction {
            buttonAction(self)
        }
    }
}

