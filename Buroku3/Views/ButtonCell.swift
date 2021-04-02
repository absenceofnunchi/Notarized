//
//  ButtonCell.swift
//  Buroku3
//
//  Created by J C on 2021-04-01.
//

import UIKit

class ButtonCell: UITableViewCell {
    var button: UIButton!
    var buttonAction: (()->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}

extension ButtonCell {
    func set(with title: String) {
        self.button.setTitle(title, for: .normal)
    }
    
    func configure() {
        button = UIButton()
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.setTitleColor(.blue, for: .normal)
        contentView.addSubview(button)
        button.fill()
    }
    
    func setConstraints() {
        
    }
    
    @objc func buttonPressed() {
        if let buttonAction = self.buttonAction {
            buttonAction()
        }
    }
}
