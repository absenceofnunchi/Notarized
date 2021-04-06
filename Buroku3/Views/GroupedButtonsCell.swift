//
//  GroupedButtonsCell.swift
//  Buroku3
//
//  Created by J C on 2021-04-05.
//

import UIKit

class GroupedButtonsCell: UITableViewCell {
    var stackView: UIStackView!
    var buttonAction: ((Int)->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension GroupedButtonsCell {
    func set(with buttonContentArr: [ButtonContent]) {
        for (index, buttonContent) in buttonContentArr.enumerated() {
            let containerView = UIView()
            
            // button
            let button = UIButton.systemButton(with: buttonContent.image, target: self, action: #selector(buttonHandler))
            button.backgroundColor = buttonContent.bgColor
            button.layer.cornerRadius = 7
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(button)
            
            // subtitle
            let titleLabel = UILabel()
            titleLabel.text = buttonContent.title
            titleLabel.textColor = .lightGray
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: containerView.topAnchor),
                button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                button.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
                    
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
                titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            stackView.addArrangedSubview(containerView)
        }
    }
    
    func configure() {
        contentView.backgroundColor = .systemGroupedBackground
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        stackView.fill()
    }
    
    func setConstraints() {
        
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        if let buttonAction = self.buttonAction {
            buttonAction(sender.tag)
        }
    }
}

struct ButtonContent {
    let title: String
    let image: UIImage
    var bgColor: UIColor = UIColor(red: 74/255, green: 71/255, blue: 163/255, alpha: 0.9)
}
