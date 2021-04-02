//
//  WebViewController.swift
//  Buroku3
//
//  Created by J C on 2021-04-01.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var hashString: String!
    var webView: WKWebView!
    let alert = Alerts()
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureWebView()
    }
}


// MARK: - Configure web view
extension WebViewController {
    func configureWebView() {
        let urlString = "https://etherscan.io/tx/0x\(hashString ?? "")"
        if let url = URL(string: urlString) {
            
            print("inside url ", urlString)
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
            
        } else {
            alert.show("Error", with: "Sorry, there was an error loading the web page.", for: self) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - delegate methods
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationController?.activityStopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityStopAnimating()
    }
}
