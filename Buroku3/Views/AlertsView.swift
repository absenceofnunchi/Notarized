//
//  AlertsView.swift
//  Buroku3
//
//  Created by J C on 2021-03-20.
//

import UIKit

class Alerts {
    func show(_ error: Error?, for controller: UIViewController) {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    typealias Action = () -> Void
    var action: Action? = { }
    
    func show(_ title: String?, with message: String?, for controller: UIViewController, completion: Action? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: completion)
        
//        if let popoverController = alert.popoverPresentationController {
//            popoverController.sourceView = self.view
//            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//        }
    }
    
    func withTextField(delegate: UITextFieldDelegate, controller: UIViewController, image: UIImage? = nil, data: Data? = nil, completion: @escaping (String, String) -> Void) {
        let ac = UIAlertController(title: "Upload to blockchain", message: "Enter the name you want to save your file as and the password of your wallet to authorize this transaction.", preferredStyle: .alert)
        
        ac.addTextField { (textField: UITextField!) in
            textField.delegate = delegate
            textField.placeholder = "Save as..."
        }
        
        ac.addTextField { (textField: UITextField!) in
            textField.delegate = delegate
            textField.placeholder = "Password for your wallet"
            textField.isSecureTextEntry = true
        }
        
        let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac](_) in
            guard let textField = ac.textFields?.first, let title = textField.text else { return }
            guard let textField2 = ac.textFields?[1], let password = textField2.text else { return }
            
            completion(title, password)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(enterAction)
        ac.addAction(cancelAction)
        DispatchQueue.main.async {
            controller.present(ac, animated: true, completion: nil)
        }
    }
    
    func withPassword(title: String, delegate: UITextFieldDelegate, controller: UIViewController, completion: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: "Enter the password of your wallet to authorize this transaction.", preferredStyle: .alert)

        ac.addTextField { (textField: UITextField!) in
            textField.delegate = delegate
            textField.placeholder = "Password for your wallet"
        }
        
        let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac](_) in
            guard let textField = ac.textFields?.first, let password = textField.text else { return }
            
            completion(password)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(enterAction)
        ac.addAction(cancelAction)
        DispatchQueue.main.async {
            controller.present(ac, animated: true, completion: nil)
        }
    }
    
    func fading(controller: UIViewController, toBePasted: String) {
        let dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.layer.cornerRadius = 10
        dimmingView.clipsToBounds = true
        controller.view.addSubview(dimmingView)
        
        let label = UILabel()
        label.text = "Copied!"
        label.textColor = .white
        label.textAlignment = .center
        label.sizeToFit()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.contentView.addSubview(label)
        
        if toBePasted != nil {
            let pasteboard = UIPasteboard.general
            pasteboard.string = toBePasted
        }
        
        NSLayoutConstraint.activate([
            dimmingView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
            dimmingView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            dimmingView.widthAnchor.constraint(equalToConstant: 150),
            dimmingView.heightAnchor.constraint(equalToConstant: 50),
            
            label.centerXAnchor.constraint(equalTo: dimmingView.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: dimmingView.contentView.centerYAnchor)
        ])
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
            dimmingView.removeFromSuperview()
            timer.invalidate()
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
