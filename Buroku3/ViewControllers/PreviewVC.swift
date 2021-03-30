//
//  PreviewVC.swift
//  Buroku3
//
//  Created by J C on 2021-03-27.
//

import UIKit
import QuickLook

class PreviewVC: QLPreviewController {
    var buttonAction: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(buttonTapped))
        self.navigationItem.rightBarButtonItems = [barButton]
        self.navigationItem.setLeftBarButtonItems([], animated: true)
        //        self.navigationItem.hidesBackButton = true
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if let buttonAction = self.buttonAction {
            buttonAction()
        }
    }
}
