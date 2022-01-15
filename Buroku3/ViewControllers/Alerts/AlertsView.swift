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
    
    func fading(controller: UIViewController, toBePasted: String?) {
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
    
    enum FadingLocation {
        case center, top
    }
    
    // MARK: - fading
    /// show a message for a brief period and disappears e.i "Copied"
    func fading(
        text: String = "Copied!",
        controller: UIViewController?,
        toBePasted: String?,
        width: CGFloat = 150,
        location: FadingLocation = .center,
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            guard let controller = controller else { return }
            let dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            dimmingView.layer.cornerRadius = 10
            dimmingView.clipsToBounds = true
            controller.view.addSubview(dimmingView)
            
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.sizeToFit()
            label.backgroundColor = .clear
            label.alpha = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            dimmingView.contentView.addSubview(label)
            
            if let tbp = toBePasted {
                let pasteboard = UIPasteboard.general
                pasteboard.string = tbp
            }
            
            NSLayoutConstraint.activate([
                dimmingView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                dimmingView.widthAnchor.constraint(equalToConstant: width),
                dimmingView.heightAnchor.constraint(equalToConstant: 150),
                
                label.centerXAnchor.constraint(equalTo: dimmingView.contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: dimmingView.contentView.centerYAnchor)
            ])
            
            if location == .center {
                NSLayoutConstraint.activate([
                    dimmingView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
                ])
            } else if location == .top {
                NSLayoutConstraint.activate([
                    dimmingView.topAnchor.constraint(equalTo: controller.view.topAnchor, constant: 200)
                ])
            }
            
            UIView.animate(withDuration: 0.3) {
                label.alpha = 1
            }
            
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                UIView.animate(withDuration: 0.3) {
                    label.alpha = 0
                }
                dimmingView.removeFromSuperview()
                timer.invalidate()
                //                controller.dismiss(animated: true, completion: nil)
            }
            
            completion?()
        }
    }
    
    func showDetail(
        _ title: String,
        with message: String?,
        height: CGFloat = 350,
        fieldViewHeight: CGFloat = 150,
        index: Int = 0,
        alignment: NSTextAlignment = .left,
        for controller: UIViewController?,
        alertStyle: AlertStyle = .oneButton,
        buttonAction: Action? = nil,
        completion: Action? = nil) {
            DispatchQueue.main.async {
                controller?.hideSpinner {
                    controller?.dismiss(animated: true, completion: {
                        let content = [
                            StandardAlertContent(
                                index: index,
                                titleString: title,
                                body: ["": message ?? ""],
                                fieldViewHeight: fieldViewHeight,
                                messageTextAlignment: alignment,
                                alertStyle: alertStyle,
                                buttonAction: { (_) in
                                    buttonAction?()
                                    controller?.dismiss(animated: true, completion: nil)
                                })
                        ]
                        let alertVC = AlertViewController(height: height, standardAlertContent: content)
                        controller?.present(alertVC, animated: true, completion: {
                            completion?()
                        })
                    })
                }
            }
        }
}
