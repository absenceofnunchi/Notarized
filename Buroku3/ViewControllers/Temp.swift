////
////  MainViewController.swift
////  Buroku3
////
////  Created by J C on 2021-03-18.
////
//
//import UIKit
//import QuickLook
//import web3swift
//import CoreSpotlight
//import MobileCoreServices
//
//class MainViewController: UIViewController {
//    var backgroundView: BackgroundView7!
//    var containerView: BlurEffectContainerView!
//    var documentPicker: DocumentPicker!
//    var url: URL!
//    var sideBarButton: UIButton!
//    var documentBrowseButton: UIButton!
//    var lowerContainerView: UIView!
//    var cameraButton: UIButton!
//    var imagePickerButton: UIButton!
//    var progressContainerView: UIView!
//    var progressTitleLabel: UILabel!
//    var progressView: UIProgressView!
//    var progressLabel: UILabel!
//    var observation: NSKeyValueObservation?
//    var fileData: Data!
//    var titleLabel: UILabel!
//    
//    let transactionService = TransactionService()
//    let alert = Alerts()
//    
//    // MARK: - viewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureBackground()
//        configureUI()
//        setConstraints()
//    }
//    
//    deinit {
//        if observation != nil {
//            observation?.invalidate()
//        }
//    }
//}
//
//extension MainViewController {
//    // MARK: - configureBackground
//    func configureBackground() {
//        backgroundView = BackgroundView7()
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(backgroundView)
//        backgroundView.fill()
//    }
//    
//    // MARK: - configureUI
//    func configureUI() {
//        // document picker
//        documentPicker = DocumentPicker(presentationController: self, delegate: self)
//        
//        titleLabel = UILabel()
//        titleLabel.text = "buroku"
//        titleLabel.sizeToFit()
//        if let roundedHeadlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline).withDesign(.rounded) {
//            let roundedFont = UIFont(descriptor: roundedHeadlineDescriptor, size: 30).with(weight: .bold)
//            titleLabel.font = roundedFont
//        }
//        titleLabel.textColor = .white
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(titleLabel)
//        
//        // container view
//        containerView = BlurEffectContainerView()
//        view.addSubview(containerView)
//        
//        // document browse button
//        documentBrowseButton = UIButton()
//        documentBrowseButton.tag = 1
//        documentBrowseButton.layer.cornerRadius = 7
//        documentBrowseButton.setTitle("Browse File", for: .normal)
//        documentBrowseButton.backgroundColor = .black
//        documentBrowseButton.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
//        documentBrowseButton.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(documentBrowseButton)
//        
//        // lower container view
//        lowerContainerView = UIView()
//        lowerContainerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(lowerContainerView)
//        
//        // camera button
//        guard let cameraImage = UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
//        cameraButton = UIButton.systemButton(with: cameraImage, target: self, action: #selector(buttonHandler))
//        cameraButton.tag = 2
//        cameraButton.layer.cornerRadius = 7
//        cameraButton.backgroundColor = .black
//        cameraButton.translatesAutoresizingMaskIntoConstraints = false
//        lowerContainerView.addSubview(cameraButton)
//        
//        // image picker button
//        guard let pickerImage = UIImage(systemName: "photo")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
//        imagePickerButton = UIButton.systemButton(with: pickerImage, target: self, action: #selector(buttonHandler))
//        imagePickerButton.tag = 3
//        imagePickerButton.layer.cornerRadius = 7
//        imagePickerButton.backgroundColor = .black
//        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
//        lowerContainerView.addSubview(imagePickerButton)
//        
//        // progress container view
//        progressContainerView = UIView()
//        progressContainerView.alpha = 0
//        progressContainerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(progressContainerView)
//        
//        // progress title label
//        progressTitleLabel = UILabel()
//        progressTitleLabel.text = "Uploading..."
//        progressTitleLabel.textColor = .gray
//        progressTitleLabel.font = UIFont.systemFont(ofSize: 12)
//        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        progressContainerView.addSubview(progressTitleLabel)
//        
//        // progress view
//        progressView = UIProgressView(progressViewStyle: .bar)
//        progressView.progress = 0.0
//        progressView.tintColor = .black
//        progressView.translatesAutoresizingMaskIntoConstraints = false
//        progressContainerView.addSubview(progressView)
//        
//        // progress label
//        progressLabel = UILabel()
//        progressLabel.textAlignment = .right
//        progressLabel.textColor = .gray
//        progressLabel.font = UIFont.systemFont(ofSize: 12)
//        progressLabel.translatesAutoresizingMaskIntoConstraints = false
//        progressContainerView.addSubview(progressLabel)
//    }
//    
//    // MARK: - setConstraints
//    func setConstraints() {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            NSLayoutConstraint.activate([
//                // container view
//                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//                containerView.heightAnchor.constraint(equalToConstant: 400),
//            ])
//        } else {
//            NSLayoutConstraint.activate([
//                // container view
//                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//                containerView.heightAnchor.constraint(equalToConstant: 300),
//            ])
//        }
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height / 5),
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            // document browse button
//            documentBrowseButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
//            documentBrowseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            documentBrowseButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
//            documentBrowseButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            // lower container view
//            lowerContainerView.topAnchor.constraint(equalTo: documentBrowseButton.bottomAnchor, constant: 50),
//            lowerContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -50),
//            lowerContainerView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
//            lowerContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            
//            // camera button
//            cameraButton.leadingAnchor.constraint(equalTo: lowerContainerView.leadingAnchor),
//            cameraButton.widthAnchor.constraint(equalTo: lowerContainerView.widthAnchor, multiplier: 0.4),
//            cameraButton.heightAnchor.constraint(equalTo: cameraButton.widthAnchor),
//            cameraButton.centerYAnchor.constraint(equalTo: lowerContainerView.centerYAnchor),
//            
//            // image picker button
//            imagePickerButton.trailingAnchor.constraint(equalTo: lowerContainerView.trailingAnchor),
//            imagePickerButton.widthAnchor.constraint(equalTo: lowerContainerView.widthAnchor, multiplier: 0.4),
//            imagePickerButton.heightAnchor.constraint(equalTo: imagePickerButton.widthAnchor),
//            imagePickerButton.centerYAnchor.constraint(equalTo: lowerContainerView.centerYAnchor),
//            
//            progressContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
//            progressContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            progressContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
//            progressContainerView.heightAnchor.constraint(equalToConstant: 200),
//            
//            // progress title label
//            progressTitleLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor, constant: -50),
//            progressTitleLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
//            progressTitleLabel.widthAnchor.constraint(equalTo: progressContainerView.widthAnchor, multiplier: 1),
//            
//            // progress view
//            progressView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),
//            progressView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
//            progressView.widthAnchor.constraint(equalTo: progressContainerView.widthAnchor, multiplier: 1),
//            
//            // progress label
//            progressLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
//            progressLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor, constant: 50),
//            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
//            progressLabel.widthAnchor.constraint(equalTo: progressContainerView.widthAnchor, multiplier: 0.8),
//        ])
//    }
//    
//    // MARK: - buttonHandler
//    @objc func buttonHandler(_ sender: UIButton!) {
//        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
//        feedbackGenerator.impactOccurred()
//        
//        switch sender.tag {
//            case 1:
//                documentPicker.displayPicker()
//            case 2:
//                let vc = UIImagePickerController()
//                vc.sourceType = .camera
//                vc.allowsEditing = true
//                vc.delegate = self
//                present(vc, animated: true)
//            case 3:
//                let imagePickerController = UIImagePickerController()
//                imagePickerController.allowsEditing = false
//                imagePickerController.sourceType = .photoLibrary
//                imagePickerController.delegate = self
//                imagePickerController.modalPresentationStyle = .fullScreen
//                present(imagePickerController, animated: true, completion: nil)
//            default:
//                break
//        }
//    }
//}
//
//// MARK: - Image picker
//extension MainViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//        
//        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
//            print("No image found")
//            return
//        }
//        
//        alert.withTextField(delegate: self, controller: self, image: image) { [weak self] (title, password) in
//            //            self?.uploadFile(fileData: image, title: title, password: password)
//            self?.presendAnimation(completion: {
//                self?.uploadImage(image: image, title: title, password: password)
//            })
//        }
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: - Document
//extension MainViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate, DocumentDelegate {
//    
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        return 1
//    }
//    
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        return self.url as QLPreviewItem
//    }
//    
//    func didPickDocument(document: Document?) {
//        if let pickedDoc = document {
//            let fileURL = pickedDoc.fileURL
//            url = fileURL
//            
//            var retrievedData: Data!
//            do {
//                retrievedData = try Data(contentsOf: fileURL)
//            } catch {
//                alert.show(error, for: self)
//            }
//            
//            let preview = PreviewVC()
//            preview.dataSource = self
//            preview.buttonAction = { [weak self] in
//                self?.dismiss(animated: true, completion: nil)
//                
//                if let data = retrievedData {
//                    self?.alert.withTextField(delegate: self!, controller: self!, data: data, completion: { (title, password) in
//                        //                        self?.uploadFile(fileData: data, title: title, password: password)
//                        
//                        self?.presendAnimation(completion: {
//                            self?.uploadData(data: data, title: title, password: password)
//                        })
//                    })
//                }
//            }
//            present(preview, animated: true, completion: nil)
//        }
//    }
//}
//
//// MARK: - Upload functions
//extension MainViewController: UITextFieldDelegate {
//    private func generateBoundaryString() -> String {
//        return "Boundary-\(Int.random(in: 1000 ... 9999))"
//    }
//    
//    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String, dataKey: Data, boundary: String, isImage: Bool) -> Data {
//        let body = NSMutableData()
//        
//        var mimetype: String!
//        
//        if isImage == true {
//            mimetype = "image/*"
//        } else {
//            mimetype = "application/*"
//        }
//        
//        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
//        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filePathKey)\"\r\n".data(using: .utf8) ?? Data())
//        body.append("Content-Type: \(mimetype!)\r\n\r\n".data(using: .utf8) ?? Data())
//        body.append(dataKey)
//        body.append("\r\n".data(using: .utf8) ?? Data())
//        body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
//        print("body", body)
//        return body as Data
//    }
//    
//    // MARK: - uploadImage
//    func uploadImage(image: UIImage, title: String, password: String) {
//        // build request URL
//        //        guard let requestURL = URL(string: "https://express-ipfs-4djcj3hprq-ue.a.run.app/addImage") else {
//        //            return
//        //        }
//        
//        guard let requestURL = URL(string: "http://localhost:8080/addImage") else {
//            return
//        }
//        
//        // prepare request
//        var request = URLRequest(url: requestURL)
//        request.httpMethod = MethodHttp.post.rawValue
//        
//        let boundary = generateBoundaryString()
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        // built data from img
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", dataKey: imageData, boundary: boundary, isImage: true)
//        }
//        
//        let task =  URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//            }
//            
//            
//            guard let response = response as? HTTPURLResponse else {
//                print("no response")
//                return
//            }
//            
//            if !(200...299).contains(response.statusCode) {
//                // handle HTTP server-side error
//                debugPrint("response", response)
//            }
//            
//            //            let contentType = response.allHeaderFields["Content-Type"] as? String
//            
//            if let data = data {
//                print("data", data)
//                //                self.uploadToBlockchain(data: data, title: title, password: password, txType: .imageUploaded)
//            }
//        })
//        
//        observation = task.progress.observe(\.fractionCompleted) { [weak self](progress, _) in
//            DispatchQueue.main.async {
//                self?.progressView.progress = Float(progress.fractionCompleted)
//                self?.progressLabel.text = String(Int(progress.fractionCompleted * 100)) + "%"
//            }
//        }
//        
//        task.resume()
//    }
//    
//    func uploadData(data: Data, title: String, password: String) {
//        // build request URL
//        guard let requestURL = URL(string: "https://express-ipfs-4djcj3hprq-ue.a.run.app/addFile") else {
//            return
//        }
//        
//        // prepare request
//        var request = URLRequest(url: requestURL)
//        request.httpMethod = MethodHttp.post.rawValue
//        
//        let boundary = generateBoundaryString()
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        // built data from img
//        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", dataKey: data, boundary: boundary, isImage: false)
//        
//        let task =  URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//            }
//            
//            let response = response as! HTTPURLResponse
//            if !(200...299).contains(response.statusCode) {
//                // handle HTTP server-side error
//                debugPrint("response", response)
//            }
//            
//            //            let contentType = response.allHeaderFields["Content-Type"] as? String
//            
//            if let data = data {
//                print("data", data)
//                //                self.uploadToBlockchain(data: data, title: title, password: password, txType: .docUploaded)
//            }
//        })
//        
//        observation = task.progress.observe(\.fractionCompleted) { [weak self](progress, _) in
//            DispatchQueue.main.async {
//                self?.progressView.progress = Float(progress.fractionCompleted)
//                self?.progressLabel.text = String(Int(progress.fractionCompleted * 100)) + "%"
//            }
//        }
//        
//        task.resume()
//    }
//    
//    // MARK: - uploadFile
//    func uploadFile(fileData: Data, title: String, password: String){
//        guard let requestURL = URL(string: "https://express-ipfs-4djcj3hprq-ue.a.run.app/addFile") else {
//            return
//        }
//        
//        var request = URLRequest(url: requestURL)
//        let boundary:String = "Boundary-\(UUID().uuidString)"
//        
//        request.httpMethod = "POST"
//        request.timeoutInterval = 10
//        request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=----\(boundary)"]
//        
//        var data: Data = Data()
//        /* Use this if you have to send a JSON too.
//         let dic:[String:Any] = [
//         "Key":Value,
//         "Key":Value
//         ]
//         
//         for (key,value) in dic{
//         data.append("------\(boundary)\r\n")
//         data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//         data.append("\(value)\r\n")
//         }
//         */
//        data.append("------\(boundary)\r\n")
//        //Here you have to change the Content-Type
//        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(title)\"\r\n")
//        data.append("Content-Type: application/*\r\n\r\n")
//        data.append(fileData)
//        data.append("\r\n")
//        data.append("------\(boundary)--")
//        request.httpBody = data
//        
//        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
//            let session = URLSession.shared
//            let task = session.dataTask(with: request, completionHandler: { [weak self](data, aResponse, error) in
//                if let error = error {
//                    DispatchQueue.main.async {
//                        self?.alert.show(error, for: self!)
//                    }
//                }
//                
//                if let data = data {
//                    self?.uploadToBlockchain(data: data, title: title, password: password, txType: .docUploaded)
//                }
//            })
//            
//            task.resume()
//        }
//    }
//    
//    // MARK: - uploadToBlockchain
//    func uploadToBlockchain(data: Data, title: String, password: String, txType: TransactionType) {
//        do {
//            if let responseObj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String:Any] {
//                if let status = responseObj["ipfs success"] as? [String: Any],
//                   let path = status["path"],
//                   let size = status["size"] as? NSNumber {
//                    
//                    print("path", path)
//                    
//                    let date = Date()
//                    let df = DateFormatter()
//                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    let dateString = df.string(from: date)
//                    
//                    let parameters = [path, dateString, size.intValue, title] as [AnyObject]
//                    transactionService.prepareTransactionForSettingFile(parameters: parameters) { [weak self](transaction, error) in
//                        if let error = error {
//                            self?.presendAnimation(isReversed: true, completion: {
//                                switch error {
//                                    case .contractLoadingError:
//                                        self?.alert.show("Error", with: "There was an error loading the contract.", for: self!)
//                                    case .createTransactionIssue:
//                                        self?.alert.show("Error", with: "There was an error creating the transaction.", for: self!)
//                                    default:
//                                        self?.alert.show("Error", with: "Sorry, there was an error uploading to the blockchain.", for: self!)
//                                }
//                            })
//                        }
//                        
//                        if let transaction = transaction {
//                            DispatchQueue.global().async {
//                                do {
//                                    let result = try transaction.send(password: password, transactionOptions: nil)
//                                    print("result from send", result)
//                                    
//                                    // save
//                                    guard let path = path as? String else {
//                                        print("path not retrieved")
//                                        return
//                                    }
//                                    
//                                    DispatchQueue.main.async {
//                                        let detailVC = DetailViewController(height: 200)
//                                        detailVC.titleString = "Success!"
//                                        detailVC.message = "Your file has been uploaded to the blockchain. It will take some time for your transaction to be mined."
//                                        detailVC.buttonAction = { _ in
//                                            self?.dismiss(animated: true, completion: nil)
//                                        }
//                                        
//                                        self?.present(detailVC, animated: true) {
//                                            self?.presendAnimation(isReversed: true, completion: {
//                                                let localDatabase = LocalDatabase()
//                                                if let wallet = localDatabase.getWallet() {
//                                                    localDatabase.saveTransactionDetail(walletAddress: wallet.address,txHash: result.hash, fileHash: path, date: Date(), txType: txType)
//                                                    
//                                                    print("result.hash after local database", result.hash)
//                                                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
//                                                    attributeSet.title = title
//                                                    attributeSet.contentCreationDate = Date()
//                                                    attributeSet.contentDescription = path
//                                                    let titleKeywords =  title.components(separatedBy: " ")
//                                                    var keywordsArr = ["productivity", "goal setting", "habit"]
//                                                    for keyword in titleKeywords {
//                                                        keywordsArr.append(keyword)
//                                                    }
//                                                    attributeSet.keywords = keywordsArr
//                                                    
//                                                    let uploadedItem = CSSearchableItem(uniqueIdentifier: "\(result.hash)", domainIdentifier: "com.ovis.Buroku3", attributeSet: attributeSet)
//                                                    uploadedItem.expirationDate = Date.distantFuture
//                                                    CSSearchableIndex.default().indexSearchableItems([uploadedItem]) { (error) in
//                                                        if let error = error {
//                                                            print("Indexing error: \(error.localizedDescription)")
//                                                        } else {
//                                                            print("Search item for Progress successfully indexed")
//                                                        }
//                                                    }
//                                                }
//                                            })
//                                        }
//                                        
//                                        //                                        let finalAC = UIAlertController(title: "Success!", message: "Your file has been uploaded to the blockchain.", preferredStyle: .alert)
//                                        //                                        finalAC.addAction(UIAlertAction(title: "OK", style: .default))
//                                        //                                        self?.present(finalAC, animated: true, completion: {
//                                        //
//                                        //                                            let localDatabase = LocalDatabase()
//                                        //                                            if let wallet = localDatabase.getWallet() {
//                                        //                                                localDatabase.saveTransactionDetail(walletAddress: wallet.address,txHash: result.hash, fileHash: path, date: Date(), txType: txType)
//                                        //
//                                        //                                                // Core Spotlight indexing for Progress
//                                        //                                                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
//                                        //                                                attributeSet.title = title
//                                        //                                                attributeSet.contentCreationDate = Date()
//                                        //                                                attributeSet.contentDescription = path
//                                        //                                                let titleKeywords =  title.components(separatedBy: " ")
//                                        //                                                var keywordsArr = ["productivity", "goal setting", "habit"]
//                                        //                                                for keyword in titleKeywords {
//                                        //                                                    keywordsArr.append(keyword)
//                                        //                                                }
//                                        //                                                attributeSet.keywords = keywordsArr
//                                        //
//                                        //                                                let progressItem = CSSearchableItem(uniqueIdentifier: "\(result.hash)", domainIdentifier: "com.ovis.Buroku3", attributeSet: attributeSet)
//                                        //                                                progressItem.expirationDate = Date.distantFuture
//                                        //                                                CSSearchableIndex.default().indexSearchableItems([progressItem]) { (error) in
//                                        //                                                    if let error = error {
//                                        //                                                        print("Indexing error: \(error.localizedDescription)")
//                                        //                                                    } else {
//                                        //                                                        print("Search item for Progress successfully indexed")
//                                        //                                                    }
//                                        //                                                }
//                                        //                                            }
//                                        //                                        })
//                                    }
//                                } catch Web3Error.nodeError(let desc) {
//                                    if let index = desc.firstIndex(of: ":") {
//                                        let newIndex = desc.index(after: index)
//                                        let newStr = desc[newIndex...]
//                                        DispatchQueue.main.async {
//                                            self?.presendAnimation(isReversed: true, completion: {
//                                                self?.alert.show("Alert", with: String(newStr), for: self!)
//                                            })
//                                        }
//                                    }
//                                } catch {
//                                    DispatchQueue.main.async {
//                                        self?.presendAnimation(isReversed: true, completion: {
//                                            self?.alert.show("Error", with: "Sorry, there was an error uploading your file to a blockchain. Please verify that your password is correct or you have enough in your wallet.", for: self!)
//                                        })
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } catch {
//            DispatchQueue.main.async { [weak self] in
//                self?.alert.show(error, for: self!)
//            }
//        }
//    }
//    
//    func presendAnimation(isReversed: Bool = false, completion: @escaping () -> Void) {
//        let totalCount = 3
//        //        let duration = 1.0 / Double(totalCount)
//        let duration = Double(0.5)
//        
//        let animation = UIViewPropertyAnimator(duration: 0.5, timingParameters: UICubicTimingParameters())
//        animation.addAnimations {
//            
//            switch isReversed {
//                case false:
//                    UIView.animateKeyframes(withDuration: 0, delay: 0, animations: { [weak self] in
//                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration) {
//                            self?.titleLabel.alpha = 0
//                        }
//                        
//                        UIView.addKeyframe(withRelativeStartTime: 1/Double(totalCount), relativeDuration: duration) {
//                            //                            self?.containerView.center = CGPoint(x: self!.view.bounds.size.width / 2, y: 250)
//                            self?.containerView.transform = CGAffineTransform(translationX: 0, y: -100)
//                        }
//                        
//                        UIView.addKeyframe(withRelativeStartTime: 1.5/Double(totalCount), relativeDuration: duration) {
//                            self?.progressContainerView.alpha = 1
//                        }
//                    })
//                    
//                    completion()
//                case true:
//                    UIView.animateKeyframes(withDuration: 0, delay: 0, animations: { [weak self] in
//                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
//                            self?.progressContainerView.alpha = 0
//                        }
//                        
//                        UIView.addKeyframe(withRelativeStartTime: 1 / Double(totalCount), relativeDuration: duration) {
//                            self?.containerView.transform = .identity
//                        }
//                        
//                        UIView.addKeyframe(withRelativeStartTime: 2 / Double(totalCount), relativeDuration: duration) {
//                            self?.titleLabel.alpha = 1
//                        }
//                    })
//                    completion()
//            }
//        }
//        
//        animation.startAnimation()
//    }
//}
//
//enum MethodHttp: String {
//    case get = "GET"
//    case post = "POST"
//}
