//
//  WebViewController.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import UIKit
import WebKit
import SVProgressHUD

class WebViewController: UIViewController {
    
    var wkWebView: WKWebView!
    
    var articleURL: URL?
    
    func makeBackButton() -> UIButton {
        let backButtonImage = UIImage(systemName: "chevron.left")
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        return backButton
    }
    
    @objc func backButtonPressed() {
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        
        // 2. Initialize webView with the frame of the screen
        wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.navigationDelegate = self
        
        // 3. Assign directly to view
        view = wkWebView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.dismiss()
    }
    
    private func setNavBarStyle() {
        self.navigationItem.title = "Article"
        
        // Standard system Close/Done button is better for Modal Full Screen
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton
        
        // Make the bar look modern (iOS 15+ scrollEdgeAppearance)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarStyle()
        
        if let articleURL {
            let request = URLRequest(url: articleURL)
            SVProgressHUD.show()
            wkWebView.load(request)
        }
    }
}


extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.dismiss()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        let label = UILabel(frame: CGRect.zero)
        label.text = "Network Issue"
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .black
        label.alpha = 0.6
        wkWebView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: wkWebView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: wkWebView.centerYAnchor).isActive = true
        
        SVProgressHUD.dismiss()
    }
    
}

