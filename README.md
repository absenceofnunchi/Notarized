# Notarized

Notarized helps you permanently store an image or a file on the Ethereum blockchain. The immutability of the blockchain allows you to definitively attest to the existence and the timestamp of your files. The blockchain works in conjunction with IPFS to store the information. Store your non-sensitive files on the public blockchain.

## App Store

https://apps.apple.com/tm/app/notarized/id1605692718

## Structure

### Front End

The iOS or the iPadOS generates or imports private/key pairs, creates Ethereum transactions, and signs public signatures (ECDSA). A user chooses either an image or a PDF file locally and uploads it to a smart contract.  The app also queries the smart contract to fetch the saved files.  Finally, IPFS files are viewable from the app.


### IPFS

The InterPlanetary File System is a protocol and peer-to-peer network for storing and sharing data in a distributed file system.  First, the front end app sends a file to [the deployed app on AWS Lambda](https://github.com/igibliss00/ipfs-express-aws). Lambda relays the file to an IPFS node to be pinned.  The IPFS node then generates a unique hash called CID derived from the pinned file and returns it back to the front end.  

An example of a CID looks as follows:

>bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi

### Smart Contract

The front end app (iOS or iPadOS) creates an Ethereum transaction including the newly acquired IPFS CID in the extra data payload.  The transaction is  sent to an Ethereum node and, after it's included in a block and mined, calls either the `setImage` or the `setDocument` method on [a smart contract](https://github.com/igibliss00/Notarized-smart-contract). The file is then permanently saved in an array on the contract. 

The contract is located at 0x3A3596B99a90937ce2C87502d977686BDaE3B734 on the Ethereum mainnet. 

## Components

### Upload to IPFS

The locally selected files are converted to a binary form and included in the HTTP body to be sent to AWS Lambda as a HTTP request. 

```swift
final func uploadToIPFS<T>(_ data: T) -> AnyPublisher<[AnyObject], PostingError> {
    let boundary = generateBoundaryString()
    var request: URLRequest!
    
    switch data {
        case let image as UIImage:
            // build request URL
            guard let requestURL = URL(string: AWS_URL_ENDPOINT) else {
                return Fail(error: PostingError.generalError(reason: "There was an error broadcasting your post to the subscribers."))
                    .eraseToAnyPublisher()
            }
            
            request = URLRequest(url: requestURL)
            request.httpMethod = MethodHttp.post.rawValue
            
            // built data from img
            if let imageData = image.jpegData(compressionQuality: 0.9) {
                request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", dataKey: imageData, boundary: boundary, isImage: true)
            }
        case let file as Data:
            guard let requestURL = URL(string: AWS_URL_ENDPOINT) else {
                return Fail(error: PostingError.generalError(reason: "There was an error broadcasting your post to the subscribers."))
                    .eraseToAnyPublisher()
            }
            
            request = URLRequest(url: requestURL)
            request.httpMethod = MethodHttp.post.rawValue
            request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", dataKey: file, boundary: boundary, isImage: false)
        default:
            break
    }
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    let session = URLSession.shared
    // request sent to AWS Lambda
    return session.dataTaskPublisher(for: request)
        .tryMap() { element -> [AnyObject] in
            // HTTP response received and parsed
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
}
```

### Upload to the Ethereum Blockchain

Using the CID obtained from the IPFS, an Ethereum transaction is created and sent to the blockchain.

```swift
final func upload<T>(_ data: T) {
    self.presendAnimation()
    self.transactionService.preLaunch { [weak self] in
        return self?.uploadAndGetEstimate(data: data) ?? Fail(error: PostingError.generalError(reason: "Unable to get the transaction gas estimate."))
            .eraseToAnyPublisher()
    } completionHandler: { [weak self] (estimates, txPackage, error) in
        if let error = error {
            self?.hideSpinner()
            self?.presendAnimation(isReversed: true)
            self?.processFailure(error)
        }
        
        if let estimates = estimates,
           let txPackage = txPackage {
            self?.executeBlockchainUpload(estimates: estimates, txPackage: txPackage)
        }
    }
}
```

## Screetshots

1. Allows users to select a local image or a PDF file either from the iOS photo gallery, camera, or the file manager.

![](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/1.png)
    
2. Ethereum wallet.

![](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/2.png)

3. Fetched list of uploaded files on the blockchain.

![](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/3.png)

4. Information regarding the fetched files from the blockchain. The preview allows the users to see the file stored on IPFS and the detail shows the Etherscan information of the file.

![](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/4.png)

5. Receive view controller to show the QR code that can be scanned, copied, or shared.

![](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/5.png)

6. Send view controller to input the recipient address as well as the amount to send.

![](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/6.png)


## Video Demo

Click on the following video for a demo walkthrough.

[![Walkthrough demo](https://github.com/igibliss00/Notarized/blob/main/ReadmeAssets/0.png)](https://www.youtube.com/watch?v=WWpheWVAs88)
