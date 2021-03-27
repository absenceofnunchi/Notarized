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
    var containerView: BlurEffectContainerView!
    var tabBar: CustomTabBar!
    var documentPicker: DocumentPicker!
    var url: URL!
    var sideBarButton: UIButton!
    var documentBrowseButton: UIButton!
    var cameraButton: UIButton!
    var imagePickerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        configureBackground()
//        configureUI()
//        configureTabBar()
//        setConstraints()
    }
}

extension MainViewController {
    
    // MARK: - configureBackground
    func configureBackground() {
        
    }
    
    // MARK: - configureUI
    func configureUI() {
        // document picker
        documentPicker = DocumentPicker(presentationController: self, delegate: self)
        
        // container view
        containerView = BlurEffectContainerView()
        view.addSubview(containerView)
        
        // document browse button
        documentBrowseButton = UIButton()
        documentBrowseButton.tag = 1
        documentBrowseButton.setTitle("Browse File", for: .normal)
        documentBrowseButton.backgroundColor = .black
        documentBrowseButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        documentBrowseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(documentBrowseButton)
        
        // camera button
        guard let cameraImage = UIImage(systemName: "camera") else { return }
        cameraButton = UIButton.systemButton(with: cameraImage, target: self, action: #selector(buttonHandler(_:)))
        cameraButton.tag = 2
        cameraButton.backgroundColor = .black
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cameraButton)

        // image picker button
        guard let pickerImage = UIImage(systemName: "photo") else { return }
        imagePickerButton = UIButton.systemButton(with: pickerImage, target: self, action: #selector(buttonHandler(_:)))
        imagePickerButton.tag = 3
        imagePickerButton.backgroundColor = .black
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imagePickerButton)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        NSLayoutConstraint.activate([
            // container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.2),
            
            // document browse button
            documentBrowseButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            documentBrowseButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            documentBrowseButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        switch sender.tag {
            case 1:
                break
            default:
                break
        }
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
