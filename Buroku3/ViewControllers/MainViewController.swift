//
//  MainViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit
import Lottie
import QuickLook

class MainViewController: UIViewController {
    var backgroundView: BackgroundView!
    let animationView = AnimationView()
    var tabBar: CustomTabBar!
    var documentPicker: DocumentPicker!
    var url: URL!
    var sideBarButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackground()
        configureUI()
        configureTabBar()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()
    }
    
}

extension MainViewController {
    
    // MARK: - Configure Background
    func configureBackground() {
        backgroundView = BackgroundView()
        view.addSubview(backgroundView)
        backgroundView.fill()
        
        // animation
        animationView.animation = Animation.named("6")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.alpha = 0
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        //        let keypath = AnimationKeypath(keys: ["**", "Fill", "**", "Color"])
        let keypath = AnimationKeypath(keypath: "**.**.**.Color")
        let colorProvider = ColorValueProvider(UIColor(red: 102/255, green: 98/255, blue: 135/255, alpha: 1).lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
        
        view.insertSubview(animationView, at: 0)
        
        let animation = UIViewPropertyAnimator(duration: 0.8, curve: .linear) {
            self.animationView.alpha = 1
        }
        animation.startAnimation()
    }
    
    func configureUI() {
        // document picker
        documentPicker = DocumentPicker(presentationController: self, delegate: self)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // animation
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200),
            animationView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            animationView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
        ])
    }
}


// MARK: - Custom tab bar

extension MainViewController: CustomTabBarDelegate {
    func tabBarDidSelect(with tag: Int) {
        switch tag {
            case 0:
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.allowsEditing = true
                vc.delegate = self
                present(vc, animated: true)
            case 1:
                let imagePickerController = UIImagePickerController()
                imagePickerController.allowsEditing = false
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.delegate = self
                present(imagePickerController, animated: true, completion: nil)
            case 2:
                documentPicker.displayPicker()
                
            default:
                break
        }
    }
    
    func configureTabBar() {
        tabBar = CustomTabBar()
        tabBar.delegate = self
        tabBar.alpha = 0
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(tabBar, aboveSubview: backgroundView)
        
        let tabBarAnimation = UIViewPropertyAnimator(duration: 1.5, curve: .easeIn) {
            self.tabBar.alpha = 1
        }
        tabBarAnimation.startAnimation()
        
        NSLayoutConstraint.activate([
            tabBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            tabBar.heightAnchor.constraint(equalToConstant: 60),
            tabBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            tabBar.trailingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            tabBar.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Image picker

extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        print(image.size)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Document

extension MainViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate, DocumentDelegate {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.url as QLPreviewItem
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
