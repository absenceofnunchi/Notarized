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
    var backgroundView: BackgroundView7!
    var containerView: BlurEffectContainerView!
    var documentPicker: DocumentPicker!
    var url: URL!
    var sideBarButton: UIButton!
    var documentBrowseButton: UIButton!
    var lowerContainerView: UIView!
    var cameraButton: UIButton!
    var imagePickerButton: UIButton!
    var progressView: UIProgressView!
    var observation: NSKeyValueObservation?
    var fileData: Data!
    
    let transactionService = TransactionService()
    let alert = Alerts()
    
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
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        NSLayoutConstraint.activate([
            // container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
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
            
            // progress view
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
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
        
        alertWithTextField(image: image) { [weak self] (title, password) in
            self?.uploadImage(image: image, title: title, password: password)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func alertWithTextField(image: UIImage? = nil, data: Data? = nil, completion: @escaping (String, String) -> Void) {
        let ac = UIAlertController(title: "Upload to blockchain", message: "Enter the name you want to save your file as and the password of your wallet to authorize this transaction.", preferredStyle: .alert)
        
        ac.addTextField { (textField: UITextField!) in
            textField.delegate = self
            textField.placeholder = "Save as..."
        }
        
        ac.addTextField { (textField: UITextField!) in
            textField.delegate = self
            textField.placeholder = "Password for your wallet"
        }
        
        let enterAction = UIAlertAction(title: "Enter", style: .default) { [unowned ac](_) in
            guard let textField = ac.textFields?.first, let title = textField.text else { return }
            guard let textField2 = ac.textFields?[1], let password = textField2.text else { return }
            
            completion(title, password)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(enterAction)
        ac.addAction(cancelAction)
        self.present(ac, animated: true, completion: nil)
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
            let preview = PreviewVC()
            preview.dataSource = self
            preview.buttonAction = { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                
                if let data = data {
                    self?.uploadFile(fileData: data)
                }
            }
            present(preview, animated: true, completion: nil)
        }
    }
}

// MARK: - Upload functions
extension MainViewController: UITextFieldDelegate {
    private func generateBoundaryString() -> String {
        return "Boundary-\(Int.random(in: 1000 ... 9999))"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String, imageDataKey: Data, boundary: String) -> Data {
        let body = NSMutableData()
        let mimetype = "image/*"
        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filePathKey)\"\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8) ?? Data())
        body.append(imageDataKey)
        body.append("\r\n".data(using: .utf8) ?? Data())
        body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        print("body", body)
        return body as Data
    }
    
    // MARK: - uploadImage
    func uploadImage(image: UIImage, title: String, password: String) {
        // build request URL
        guard let requestURL = URL(string: "https://express-ipfs-4djcj3hprq-ue.a.run.app/addImage") else {
            return
        }
        
        // prepare request
        var request = URLRequest(url: requestURL)
        request.httpMethod = MethodHttp.post.rawValue
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // built data from img
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        }
        
        let task =  URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
            let response = response as! HTTPURLResponse
            if !(200...299).contains(response.statusCode) {
                // handle HTTP server-side error
                debugPrint("response", response)
            }
            
            if let data = data {
                print("data after ipfs", data)
                self.uploadToBlockchain(data: data, title: title, password: password)
            }
        })
        
        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress.fractionCompleted)
            }
        }
        
        task.resume()
    }
    
    // MARK: - uploadFile
    func uploadFile(fileData: Data){
        guard let requestURL = URL(string: "https://express-ipfs-4djcj3hprq-ue.a.run.app/addFile") else {
            return
        }
        
        var request = URLRequest(url: requestURL)
        let boundary:String = "Boundary-\(UUID().uuidString)"
        
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=----\(boundary)"]
        
        var data: Data = Data()
        /* Use this if you have to send a JSON too.
         let dic:[String:Any] = [
         "Key":Value,
         "Key":Value
         ]
         
         for (key,value) in dic{
         data.append("------\(boundary)\r\n")
         data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
         data.append("\(value)\r\n")
         }
         */
        data.append("------\(boundary)\r\n")
        //Here you have to change the Content-Type
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"YourFileName\"\r\n")
        data.append("Content-Type: application/YourType\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
        data.append("------\(boundary)--")
        
        request.httpBody = data
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { (dataS, aResponse, error) in
                if let error = error {
                    print("task error", error)
                }else{
                    do{
                        let responseObj = try JSONSerialization.jsonObject(with: dataS!, options: JSONSerialization.ReadingOptions(rawValue:0)) as! [String:Any]
                        print("res ob", responseObj)
                    }catch {
                        print("response obj error", error)
                    }
                }
            })
            
            task.resume()
        }
    }
    
    // MARK: - uploadToBlockchain
    func uploadToBlockchain(data: Data, title: String, password: String) {
        do {
            if let responseObj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String:Any] {
                if let status = responseObj["ipfs success"] as? [String: Any],
                   let path = status["path"],
                   let size = status["size"] as? NSNumber {
                    
                    let date = Date()
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString = df.string(from: date)
                    
                    let parameters = [path, dateString, size.intValue, title] as [AnyObject]
                    transactionService.prepareTransactionForSettingFile(parameters: parameters) { [weak self](transaction, error) in
                        if let error = error {
                            switch error {
                                case .contractLoadingError:
                                    print("contractLoadingError")
                                case .createTransactionIssue:
                                    print("createTransactionIssue")
                                default:
                                    break
                            }
                        }
                        
                        if let transaction = transaction {
                            DispatchQueue.global().async {
                                do {
                                    let result = try transaction.send(password: password, transactionOptions: nil)
                                    print("result", result)
                                    
                                    DispatchQueue.main.async {
                                        let finalAC = UIAlertController(title: "Success!", message: "Your file has been uploaded to the blockchain.", preferredStyle: .alert)
                                        finalAC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                            self?.dismiss(animated: true, completion: nil)
                                        }))
                                        self?.present(finalAC, animated: true, completion: nil)
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        self?.alert.show("Error", with: "Sorry, there was an error uploading your file to a blockchain.", for: self!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } catch {
            print("upload to blockchain error", error)
        }
        
    }
}

enum MethodHttp: String {
    case get = "GET"
    case post = "POST"
}
