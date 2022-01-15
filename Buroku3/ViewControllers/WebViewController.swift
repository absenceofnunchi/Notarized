//
//  WebViewController.swift
//  Buroku3
//
//  Created by J C on 2021-04-01.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var urlString: String!
    var webView: WKWebView!
    let alert = Alerts()
//    var navBarTintColor: UIColor! = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)
    var navBarTintColor: UIColor!
    var navBgColor: UIColor!
    
    init(navBarTintColor: UIColor? = UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1)) {
        super.init(nibName: nil, bundle: nil)
        self.navigationController?.navigationBar.tintColor = navBarTintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationBar(color: navBarTintColor ?? UIColor(red: 112/255, green: 159/255, blue: 176/255, alpha: 1), bgColor: navBgColor ?? UIColor.white)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        configureNavigationBar(color: .white, bgColor: .clear)
        configureNavigationBar()
    }

}


// MARK: - Configure web view
extension WebViewController {
    func configureNavigationBar(color: UIColor, bgColor: UIColor) {
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.standardAppearance.backgroundColor = bgColor
//        if let parent = self.parent {
//            let navigationBar = parent.navigationController?.navigationBar
//            navigationBar?.tintColor = color
//            navigationBar?.standardAppearance.backgroundColor = bgColor
//        }
    }
    
    func configureNavigationBar() {
        if let parent = self.parent {
            let navigationBar = parent.navigationController?.navigationBar
            navigationBar?.tintColor = .white
            navigationBar?.standardAppearance.backgroundColor = .clear
        }
    }
    
    
    func configureWebView() {
        if let url = URL(string: urlString) {
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
        self.activityStopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityStopAnimating()
        self.activityStopAnimating()
    }
}
