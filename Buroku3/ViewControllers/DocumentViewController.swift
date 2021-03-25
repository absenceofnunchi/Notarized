//
//  ViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-16.
//

import UIKit
import QuickLook
import Lottie

class DocumentViewController: UIViewController, DocumentDelegate {
    
    var stackView: UIStackView!
    var cameraButton: UIButton!
    var imagePickerButton: UIButton!
    var documentPickerButton: UIButton!
    var documentPicker: DocumentPicker!
    var url: URL!
    let animationView = AnimationView()
    var label: UILabel!
    var counter = 1
    var counterButton: UIButton!
    var backButton: UIButton!
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureLabel()
        configureAnimation()
        setConstraints()

        createAnimation(ct: counter)
    }
    
    func didPickDocument(document: Document?) {
        if let pickedDoc = document {
            let fileURL = pickedDoc.fileURL
            url = fileURL
            print("fileURL", fileURL)
            
            let data = try? Data(contentsOf: fileURL)
            print("data", data)
            
            let preview = QLPreviewController()
            preview.dataSource = self
            present(preview, animated: true, completion: nil)
        }
    }
}

extension DocumentViewController {
    // MARK: - Configure
    
    func configure() {
        documentPicker = DocumentPicker(presentationController: self, delegate: self)
        
        // container view
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // counter button
        counterButton = UIButton()
        counterButton.tag = 4
        counterButton.layer.borderWidth = 1
        counterButton.layer.borderColor = UIColor.lightGray.cgColor
        counterButton.layer.cornerRadius = 10
        counterButton.setTitleColor(.gray, for: .normal)
        counterButton.setTitle("+", for: .normal)
        counterButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        counterButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(counterButton)
        
        // back button
        backButton = UIButton()
        backButton.tag = 5
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.lightGray.cgColor
        backButton.layer.cornerRadius = 10
        backButton.setTitleColor(.gray, for: .normal)
        backButton.setTitle("-", for: .normal)
        backButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backButton)
        
        // camera button
        cameraButton = UIButton()
        cameraButton.tag = 1
        cameraButton.layer.borderWidth = 1
        cameraButton.layer.borderColor = UIColor.lightGray.cgColor
        cameraButton.layer.cornerRadius = 10
        cameraButton.setTitleColor(.gray, for: .normal)
        cameraButton.setTitle("Camera", for: .normal)
        cameraButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false

        // image picker
        imagePickerButton = UIButton()
        imagePickerButton.tag = 2
        imagePickerButton.layer.borderWidth = 1
        imagePickerButton.layer.borderColor = UIColor.lightGray.cgColor
        imagePickerButton.layer.cornerRadius = 10
        imagePickerButton.setTitleColor(.gray, for: .normal)
        imagePickerButton.setTitle("Image Picker", for: .normal)
        imagePickerButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        
        // document picker
        documentPickerButton = UIButton()
        documentPickerButton.tag = 3
        documentPickerButton.layer.borderWidth = 1
        documentPickerButton.layer.borderColor = UIColor.lightGray.cgColor
        documentPickerButton.layer.cornerRadius = 10
        documentPickerButton.setTitleColor(.gray, for: .normal)
        documentPickerButton.setTitle("File Manager", for: .normal)
        documentPickerButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        documentPickerButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(arrangedSubviews: [cameraButton, imagePickerButton, documentPickerButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 15  
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    }
    
    func configureBackground() {
        
    }
    
    // MARK: - Constraints
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.5),
            
            // counter button
            containerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            counterButton.widthAnchor.constraint(equalToConstant: 50),
            counterButton.heightAnchor.constraint(equalToConstant: 50),
            counterButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),

            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // text label
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.bottomAnchor, constant: 10),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.70),
            label.heightAnchor.constraint(equalToConstant: 100),
            
            // animation
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Button handler
    
    @objc func buttonHandler(_ sender: UIButton) {
        switch sender.tag {
            case 1:
                break
            case 2:
                break
            case 3:
                documentPicker.displayPicker()
            case 4:
                print("counter", counter)
                if counter >= 33 {
                    counter = 1
                } else {
                    counter += 1
                }
                createAnimation(ct: counter)
            case 5:
                if counter <= 1 {
                    counter = 33
                } else {
                    counter -= 1
                }
                createAnimation(ct: counter)
            default:
                break
        }
    }
}

extension DocumentViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.url as QLPreviewItem
    }
}

// MARK: - Create animation

extension DocumentViewController {
    func createAnimation(ct:Int) {
        var animationName: String!
        
        switch ct {
            case 1:
                animationName = "1"
            case 2:
                animationName = "2"
            case 3:
                animationName = "3"
            case 4:
                animationName = "4"
            case 5:
                animationName = "5"
            case 6:
                animationName = "6"
            case 7:
                animationName = "12"
            case 8:
                animationName = "8"
            case 9:
                animationName = "9"
            case 10:
                animationName = "11"
            case 11:
                animationName = "12"
            case 12:
                animationName = "12818-file-recover"
            case 13:
                animationName = "13893-eco-living"
            case 14:
                animationName = "15509-smart-city-blue-lines"
            case 15:
                animationName = "19167-mobile-application-testing"
            case 16:
                animationName = "19169-user-testing"
            case 17:
                animationName = "19172-usability-testing"
            case 18:
                animationName = "21397-man-using-printing-machine"
            case 19:
                animationName = "21472-code-debugging"
            case 20:
                animationName = "21638-man-working-in-office"
            case 21:
                animationName = "23403-watch-videos"
            case 22:
                animationName = "23465-send-message"
            case 23:
                animationName = "23675-read-a-book"
            case 24:
                animationName = "23693-mobile-tap-interaction-animation"
            case 25:
                animationName = "24016-nature-landscape-loading-animation"
            case 26:
                animationName = "24127-buying-a-property"
            case 27:
                animationName = "24139-ecoomerce-payment"
            case 28:
                animationName = "24271-teamwork"
            case 29:
                animationName = "25216-team-work"
            case 30:
                animationName = "25920-questions"
            case 31:
                animationName = "27476-smart-city-new-concept"
            case 32:
                animationName = "29227-creative"
            case 33:
                animationName = "37935-files-melting-process-concept-isometric-animation"
            default:
                break
        }
        
        label.text = String(counter)
        animationView.animation = Animation.named(animationName)
        animationView.play()
    }
}

// MARK: - Configure label, configure animation

extension DocumentViewController {
    func configureLabel(with text: String = "1") {
        label = UILabel()
        label.text = text
        label.textColor = .lightGray
        label.sizeToFit()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let animation = UIViewPropertyAnimator(duration: 0.8, curve: .linear) {
            self.label.alpha = 1
        }
        animation.startAnimation()
    }
    
    func configureAnimation(with name: String = "1") {
        animationView.animation = Animation.named(name)
        animationView.frame = view.bounds
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.alpha = 0
        
        // color
        let keypath = AnimationKeypath(keypath: "**.**.**.Color")
        let colorProvider = ColorValueProvider(UIColor(red: 175/255, green: 122/255, blue: 197/255, alpha: 1).lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
        
        animationView.play()
        view.addSubview(animationView)
        
        let animation = UIViewPropertyAnimator(duration: 0.8, curve: .linear) {
            self.animationView.alpha = 1
        }
        animation.startAnimation()
    }
}
