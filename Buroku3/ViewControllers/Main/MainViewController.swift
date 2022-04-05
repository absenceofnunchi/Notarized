//
//  MainViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit
import QuickLook
import web3swift
import Combine

class MainViewController: UIViewController {
    var backgroundView: BackgroundView7!
    var containerView: BlurEffectContainerView!
    var documentPicker: DocumentPicker!
    var url: URL!
    var sideBarButton: UIButton!
    var documentBrowseButton: UIButton!
    var lowerContainerView: UIView!
    var cameraButton: UIButton!
    var imagePickerButton: UIButton!
    var progressContainerView: UIView!
    var progressTitleLabel: UILabel!
    var progressView: UIProgressView!
    var progressLabel: UILabel!
    var observation: NSKeyValueObservation?
    var fileData: Data!
    var titleLabel: UILabel!

    let transactionService = TransactionService()
    var cancellables = Set<AnyCancellable>()
    var alert: Alerts = Alerts()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackground()
        configureUI()
        setConstraints()
    }
    
    deinit {
        if observation != nil {
            observation?.invalidate()
        }
    }
}

extension MainViewController {
    // MARK: - configureBackground
    func configureBackground() {
        backgroundView = BackgroundView7()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        backgroundView.fill()
    }
    
    // MARK: - configureUI
    func configureUI() {
        // document picker
        documentPicker = DocumentPicker(presentationController: self, delegate: self)
        
        titleLabel = UILabel()
        titleLabel.text = "notorized"
        titleLabel.sizeToFit()
        if let roundedHeadlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline).withDesign(.rounded) {
            let roundedFont = UIFont(descriptor: roundedHeadlineDescriptor, size: 30).with(weight: .bold)
            titleLabel.font = roundedFont
        }
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // container view
        containerView = BlurEffectContainerView()
        view.addSubview(containerView)
        
        // document browse button
        documentBrowseButton = UIButton()
        documentBrowseButton.tag = 1
        documentBrowseButton.layer.cornerRadius = 7
        documentBrowseButton.setTitle("Browse File", for: .normal)
        documentBrowseButton.backgroundColor = .black
        documentBrowseButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        documentBrowseButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(documentBrowseButton)
        
        // lower container view
        lowerContainerView = UIView()
        lowerContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(lowerContainerView)
        
        // camera button
        guard let cameraImage = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
        cameraButton = UIButton.systemButton(with: cameraImage, target: self, action: #selector(buttonHandler))
        cameraButton.tag = 2
        cameraButton.layer.cornerRadius = 7
        cameraButton.backgroundColor = .black
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        lowerContainerView.addSubview(cameraButton)
        
        // image picker button
        guard let pickerImage = UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
        imagePickerButton = UIButton.systemButton(with: pickerImage, target: self, action: #selector(buttonHandler))
        imagePickerButton.tag = 3
        imagePickerButton.layer.cornerRadius = 7
        imagePickerButton.backgroundColor = .black
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        lowerContainerView.addSubview(imagePickerButton)
        
        // progress container view
        progressContainerView = UIView()
        progressContainerView.alpha = 0
        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressContainerView)
        
        // progress title label
        progressTitleLabel = UILabel()
        progressTitleLabel.text = "Uploading..."
        progressTitleLabel.textColor = .gray
        progressTitleLabel.font = UIFont.systemFont(ofSize: 12)
        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressTitleLabel)
        
        // progress view
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress = 0.0
        progressView.tintColor = .black
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressView)
        
        // progress label
        progressLabel = UILabel()
        progressLabel.textAlignment = .right
        progressLabel.textColor = .gray
        progressLabel.font = UIFont.systemFont(ofSize: 12)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainerView.addSubview(progressLabel)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                // container view
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                containerView.heightAnchor.constraint(equalToConstant: 400),
            ])
        } else {
            NSLayoutConstraint.activate([
                // container view
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                containerView.heightAnchor.constraint(equalToConstant: 300),
            ])
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height / 5),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // document browse button
            documentBrowseButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
            documentBrowseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            documentBrowseButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            documentBrowseButton.heightAnchor.constraint(equalToConstant: 50),
            
            // lower container view
            lowerContainerView.topAnchor.constraint(equalTo: documentBrowseButton.bottomAnchor, constant: 50),
            lowerContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -50),
            lowerContainerView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            lowerContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // camera button
            cameraButton.leadingAnchor.constraint(equalTo: lowerContainerView.leadingAnchor),
            cameraButton.widthAnchor.constraint(equalTo: lowerContainerView.widthAnchor, multiplier: 0.4),
            cameraButton.heightAnchor.constraint(equalTo: cameraButton.widthAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: lowerContainerView.centerYAnchor),
            
            // image picker button
            imagePickerButton.trailingAnchor.constraint(equalTo: lowerContainerView.trailingAnchor),
            imagePickerButton.widthAnchor.constraint(equalTo: lowerContainerView.widthAnchor, multiplier: 0.4),
            imagePickerButton.heightAnchor.constraint(equalTo: imagePickerButton.widthAnchor),
            imagePickerButton.centerYAnchor.constraint(equalTo: lowerContainerView.centerYAnchor),
            
            progressContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            progressContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            progressContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            // progress title label
            progressTitleLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor, constant: -50),
            progressTitleLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
            progressTitleLabel.widthAnchor.constraint(equalTo: progressContainerView.widthAnchor, multiplier: 1),
            
            // progress view
            progressView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),
            progressView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: progressContainerView.widthAnchor, multiplier: 1),
            
            // progress label
            progressLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor, constant: 50),
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            progressLabel.widthAnchor.constraint(equalTo: progressContainerView.widthAnchor, multiplier: 0.8),
        ])
    }
    
    // MARK: - buttonHandler
    @objc func buttonHandler(_ sender: UIButton!) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        switch sender.tag {
            case 1:
                documentPicker.displayPicker()
            case 2:
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.allowsEditing = true
                vc.delegate = self
                present(vc, animated: true)
            case 3:
                let imagePickerController = UIImagePickerController()
                imagePickerController.allowsEditing = false
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.delegate = self
                imagePickerController.modalPresentationStyle = .fullScreen
                present(imagePickerController, animated: true, completion: nil)
            default:
                break
        }
    }
}

// MARK: - Image picker
extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.upload(image)
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
            
            var retrievedData: Data!
            do {
                retrievedData = try Data(contentsOf: fileURL)
            } catch {
                alert.show(error, for: self)
            }
            
            let preview = PreviewVC()
            preview.dataSource = self
            preview.buttonAction = { [weak self] in
                self?.dismiss(animated: true, completion: nil)

                if let data = retrievedData {
                    self?.upload(data)
                }
            }
            present(preview, animated: true, completion: nil)
        }
    }
}


