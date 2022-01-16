//
//  MainViewController + Upload.swift
//  Buroku3
//
//  Created by J C on 2022-01-13.
//

/*
 Abstract:
 Upload extension for MainVC. Uploads both images and files to IPFS and then to the blockchain using the CID.
 */

import UIKit
import Combine

extension MainViewController: HandleError {
    final func upload<T>(_ data: T) {
        self.transactionService.preLaunch { [weak self] in
            return self?.uploadAndGetEstimate(data: data) ?? Fail(error: PostingError.generalError(reason: "Unable to get the transaction gas estimate."))
                .eraseToAnyPublisher()
        } completionHandler: { [weak self] (estimates, txPackage, error) in
            if let error = error {
                self?.processFailure(error)
            }
            
            if let estimates = estimates,
               let txPackage = txPackage {
                self?.executeBlockchainUpload(estimates: estimates, txPackage: txPackage)
            }
        }
    }
}

/*
 Send an image or a file to IPFS and fetch the CID
 */
extension MainViewController {
    private func generateBoundaryString() -> String {
        return "Boundary-\(Int.random(in: 1000 ... 9999))"
    }
    
    private func createBodyWithParameters(parameters: [String: String]?, filePathKey: String, dataKey: Data, boundary: String, isImage: Bool) -> Data {
        let body = NSMutableData()
        
        var mimetype: String!
        
        if isImage == true {
            mimetype = "image/*"
        } else {
            mimetype = "application/*"
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filePathKey)\"\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Type: \(mimetype!)\r\n\r\n".data(using: .utf8) ?? Data())
        body.append(dataKey)
        body.append("\r\n".data(using: .utf8) ?? Data())
        body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        print("body", body)
        return body as Data
    }
    
    final func uploadToIPFS<T>(_ data: T) -> AnyPublisher<[AnyObject], PostingError> {
        let boundary = generateBoundaryString()
        var request: URLRequest!
        
        switch data {
            case let image as UIImage:
                // build request URL
//                guard let requestURL = URL(string: "https://rnomzrlwo6.execute-api.us-east-1.amazonaws.com/addImage") else {
//                    return Fail(error: PostingError.generalError(reason: "There was an error broadcasting your post to the subscribers."))
//                        .eraseToAnyPublisher()
//                }
                
                guard let requestURL = URL(string: "http://localhost:3000/addImage") else {
                    return Fail(error: PostingError.generalError(reason: "There was an error broadcasting your post to the subscribers."))
                        .eraseToAnyPublisher()
                }
                
                request = URLRequest(url: requestURL)
                request.httpMethod = MethodHttp.post.rawValue
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                // built data from img
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", dataKey: imageData, boundary: boundary, isImage: true)
                }
            case let file as Data:
                guard let requestURL = URL(string: "https://rnomzrlwo6.execute-api.us-east-1.amazonaws.com/addFile") else {
                    return Fail(error: PostingError.generalError(reason: "There was an error broadcasting your post to the subscribers."))
                        .eraseToAnyPublisher()
                }
                
                //        guard let requestURL = URL(string: "http://localhost:3000/addFile") else {
                //            return Fail(error: PostingError.generalError(reason: "There was an error broadcasting your post to the subscribers."))
                //                .eraseToAnyPublisher()
                //        }
                
                request = URLRequest(url: requestURL)
                request.httpMethod = MethodHttp.post.rawValue
                request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", dataKey: file, boundary: boundary, isImage: false)
            default:
                break
        }
        
        
        let session = URLSession.shared
        return session.dataTaskPublisher(for: request)
            .tryMap() { element -> [AnyObject] in
                if let httpResponse = element.response as? HTTPURLResponse,
                   let httpStatusCode = APIError.HTTPStatusCode(rawValue: httpResponse.statusCode) {
                    if !(200...299).contains(httpResponse.statusCode) {
                        throw PostingError.apiError(APIError.generalError(reason: httpStatusCode.description))
                    }
                }
                
                do {
                    guard let responseObj = try JSONSerialization.jsonObject(with: element.data, options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String:Any],
                          let status = responseObj["ipfs success"] as? [String: Any],
                          let path = status["path"],
                          let size = status["size"] as? NSNumber else {
                              throw PostingError.apiError(APIError.generalError(reason: "Unable to parse the result from IPFS"))
                    }
                                        
                    let date = Date()
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString = df.string(from: date)
                    let title: String = "0"
                    let parameters: [AnyObject] = [path, dateString, size.intValue, title] as [AnyObject]
                    return parameters
                } catch {
                    throw PostingError.apiError(APIError.generalError(reason: "Unable to parse the result from IPFS"))
                }
            }
            .mapError { $0 as? PostingError ?? PostingError.generalError(reason: "Unknown Error") }
            .eraseToAnyPublisher()
    }
    
    func uploadAndGetEstimate<T>(data: T) -> AnyPublisher<TxPackage, PostingError> {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        return Deferred { [weak self] () -> AnyPublisher<[AnyObject], PostingError>  in
            return self?.uploadToIPFS(data) ?? Fail(error: PostingError.generalError(reason: "Unable to upload to IPFS."))
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
        .flatMap { [weak self] (param) -> AnyPublisher<TxPackage, PostingError>  in
            self?.activityStopAnimating()
            return Future<TxPackage, PostingError> { [weak self] promise in
                self?.transactionService.prepareTransactionForSettingFile(
                    .setFile,
                    parameters: param as [AnyObject],
                    promise: promise
                )
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

/*
 Execute the transaction by uploading to the blockchain
 */
extension MainViewController {
    // MARK: - executeBlockchainUpload
    func executeBlockchainUpload(
        estimates: (totalGasCost: String, balance: String, gasPriceInGwei: String),
        txPackage: TxPackage
    ) {
        let content = [
            StandardAlertContent(
                titleString: "Enter Your Password",
                body: ["Wallet password required": ""],
                isEditable: true,
                fieldViewHeight: 40,
                messageTextAlignment: .left,
                alertStyle: .withCancelButton
            ),
            StandardAlertContent(
                index: 1,
                titleString: "Gas Estimate",
                titleColor: UIColor.white,
                body: [
                    "Total Gas Units": txPackage.gasEstimate.description,
                    "Gas Price": "\(estimates.gasPriceInGwei) Gwei",
                    "Total Gas Cost": "\(estimates.totalGasCost) Ether",
                    "Your Current Balance": "\(estimates.balance) Ether"
                ],
                isEditable: false,
                fieldViewHeight: 40,
                messageTextAlignment: .left,
                alertStyle: .noButton
            )
        ]
        
        self.hideSpinner()
        
        DispatchQueue.main.async { [weak self] in
            let alertVC = AlertViewController(height: 350, standardAlertContent: content)
            alertVC.action = { [weak self] (modal, mainVC) in
                mainVC.buttonAction = { _ in
                    guard let password = modal.dataDict["Wallet password required"],
                          !password.isEmpty else {
                              self?.alert.fading(text: "Password cannot be empty!", controller: mainVC, toBePasted: nil, width: 250)
                              return
                          }
                    
                    self?.dismiss(animated: true, completion: {
                        self?.showSpinner()
                        
                        Deferred {
                            Future<Bool, PostingError> { promise in
                                DispatchQueue.global().async {
                                    do {
                                        let result = try txPackage.transaction.send(password: password, transactionOptions: nil)
                                        print("result", result)
                                        promise(.success(true))
                                    } catch {
                                        promise(.failure(PostingError.generalError(reason: "Unable to execute the transaction. Please doublecheck your password.")))
                                    }
                                }
                            }
                        }
                        .sink { completion in
                            switch completion {
                                case .failure(let error):
                                    self?.processFailure(error)
                                case .finished:
                                    self?.alert.showDetail(
                                        "Success!",
                                        with: "Your item has been posted. It will be reflected on the blockchain after the block has been mined.",
                                        for: self)
                            }
                        } receiveValue: { (_) in }
                        .store(in: &self!.cancellables)
                    })
                    
                } // mainVC
            } // alertVC.action
            self?.present(alertVC, animated: true, completion: nil)
        }
    }
}

enum MethodHttp: String {
    case get = "GET"
    case post = "POST"
}
