//
//  DetailViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-21.
//

import UIKit

class DetailViewController: UIViewController {
    var info: String!
    var walletLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
    }
}

extension DetailViewController {
    func configureUI() {
        view.backgroundColor = .white

        walletLabel = UILabel()
        walletLabel.text = info
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(walletLabel)
    }
    
    // MARK: - SetConstraints
    func setConstraints() {
        NSLayoutConstraint.activate([
            walletLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            walletLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walletLabel.widthAnchor.constraint(equalToConstant: 200),
            walletLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
