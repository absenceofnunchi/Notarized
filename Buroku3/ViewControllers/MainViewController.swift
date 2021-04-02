//
//  MainViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit
import Lottie
import QuickLook
import web3swift

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
        
        alert.withTextField(delegate: self, controller: self, image: image) { [weak self] (title, password) in
            self?.uploadImage(image: image, title: title, password: password)
        }
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
                    self?.alert.withTextField(delegate: self!, controller: self!, data: data, completion: { (title, password) in
                        self?.uploadFile(fileData: data, title: title, password: password)
                    })
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
    func uploadFile(fileData: Data, title: String, password: String){
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
            let task = session.dataTask(with: request, completionHandler: { [weak self](data, aResponse, error) in
                if let error = error {
                    self?.alert.show(error, for: self!)
                }
                
                if let data = data {
                    self?.uploadToBlockchain(data: data, title: title, password: password)
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
                    
                    print("path", path)
                    print("size", size.intValue)
                    
                    
                    let parameters = [path, dateString, size.intValue, title] as [AnyObject]
                    transactionService.prepareTransactionForSettingFile(parameters: parameters) { [weak self](transaction, error) in
                        if let error = error {
                            switch error {
                                case .contractLoadingError:
                                    DispatchQueue.main.async {
                                        self?.alert.show("Error", with: "There was an error loading the contract.", for: self!)
                                    }
                                case .createTransactionIssue:
                                    DispatchQueue.main.async {
                                        self?.alert.show("Error", with: "There was an error creating the transaction.", for: self!)
                                    }
                                default:
                                    DispatchQueue.main.async {
                                        self?.alert.show("Error", with: "Sorry, there was an error uploading to the blockchain.", for: self!)
                                    }
                            }
                        }
                        
                        if let transaction = transaction {
                            DispatchQueue.global().async {
                                do {
                                    let result = try transaction.send(password: password, transactionOptions: nil)
                                    print("result from send", result)
                                    
                                    // save
                                    guard let path = path as? String else {
                                        print("path not retrieved")
                                        return
                                    }
                                    
                                    let localDatabase = LocalDatabase()
                                    localDatabase.saveTransactionDetail(txHash: result.hash, fileHash: path, date: Date())
                                    
                                    DispatchQueue.main.async {
                                        let finalAC = UIAlertController(title: "Success!", message: "Your file has been uploaded to the blockchain.", preferredStyle: .alert)
                                        finalAC.addAction(UIAlertAction(title: "OK", style: .default))
                                        self?.present(finalAC, animated: true, completion: nil)
                                    }
                                } catch Web3Error.nodeError(let desc) {
                                    if let index = desc.firstIndex(of: ":") {
                                        let newIndex = desc.index(after: index)
                                        let newStr = desc[newIndex...]
                                        DispatchQueue.main.async {
                                            self?.alert.show("Alert", with: String(newStr), for: self!)
                                        }
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        self?.alert.show("Error", with: "Sorry, there was an error uploading your file to a blockchain. Please verify that your password is correct.", for: self!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } catch {
            alert.show(error, for: self)
        }
    }
}

enum MethodHttp: String {
    case get = "GET"
    case post = "POST"
}


//path QmRFaAjp7DbJbR5gCWqi3YUP1j2mtmkR5ycadGj38zA5Xg
//size 41588
//result from send TransactionSendingResult(transaction: Transaction
//                                          Nonce: 8
//                                          Gas price: 1000000000
//                                          Gas limit: 215352
//                                          To: 0xa276B436e35a76E96Bd47aDF2ec6e055433c76E2
//                                          Value: 0
//                                          Data: 0x0e35f95a000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000a2740000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000002e516d524661416a703744624a625235674357716933595550316a326d746d6b523579636164476a33387a413558670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000013323032312d30342d30322030303a32363a3037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003646f630000000000000000000000000000000000000000000000000000000000
//                                          v: 44
//                                          r: 7574277574799132992794004946874512288298215552507783879242588293639620668450
//                                          s: 18980064760772690692073485455370694255269313616131795825427837027448019977656
//                                          Intrinsic chainID: Optional(4)
//                                          Infered chainID: Optional(4)
//                                          sender: Optional("0xb007c5a9AE516Fde594D1EB1240068C32Bfa6669")
//                                          hash: Optional("0x8317aff9aa3937e188869b2a0d73e61fc644821127bc49be97024ce9d0246150")
//                                          , hash: "0x8317aff9aa3937e188869b2a0d73e61fc644821127bc49be97024ce9d0246150")

//path QmTiziYRGbboLu8MgKoqdUb6YPaqcjNdSPGYfC8hegkXXB
//size 122659
//result from send TransactionSendingResult(transaction: Transaction
//                                          Nonce: 7
//                                          Gas price: 1000000000
//                                          Gas limit: 215364
//                                          To: 0xa276B436e35a76E96Bd47aDF2ec6e055433c76E2
//                                          Value: 0
//                                          Data: 0x0e35f95a000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000001df230000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000002e516d54697a6959524762626f4c75384d674b6f716455623659506171636a4e64535047596643386865676b5858420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000013323032312d30342d30322030303a32323a31380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000037069630000000000000000000000000000000000000000000000000000000000
//                                          v: 44
//                                          r: 91055262493689418372330695502260511544052726525900338040982716471224311363683
//                                          s: 54463489728768820357537306614686117396227094691913088853915925520198575702571
//                                          Intrinsic chainID: Optional(4)
//                                          Infered chainID: Optional(4)
//                                          sender: Optional("0xb007c5a9AE516Fde594D1EB1240068C32Bfa6669")
//                                          hash: Optional("0xd279725747f8fd2dbdda69732c1745f34add35d40a5baae89153409f031791be")
//                                          , hash: "0xd279725747f8fd2dbdda69732c1745f34add35d40a5baae89153409f031791be")
