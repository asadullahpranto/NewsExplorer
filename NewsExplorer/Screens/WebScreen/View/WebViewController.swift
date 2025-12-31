//
//  WebViewController.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    // MARK: - Properties
    private var wkWebView: WKWebView!
    var articleURL: URL?
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.tintColor = .systemBlue
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.navigationDelegate = self
        view = wkWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupProgressView()
        setupObserver()
        loadContent()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.title = "Article"

        if isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(handleDismiss)
            )
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        view.bringSubviewToFront(progressView)
    }
    
    private func setupObserver() {
        estimatedProgressObserver = wkWebView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            self.progressView.progress = Float(webView.estimatedProgress)
            
            let isFinished = webView.estimatedProgress >= 1.0
            UIView.animate(withDuration: 0.3, animations: {
                self.progressView.alpha = isFinished ? 0 : 1
            }) { _ in
                if isFinished { self.progressView.progress = 0 }
            }
        }
    }
    
    private func loadContent() {
        guard let url = articleURL else { return }
        wkWebView.load(URLRequest(url: url))
    }
    
    @objc private func handleDismiss() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showErrorState()
    }
    
    private func showErrorState() {
        let errorLabel = UILabel()
        errorLabel.text = "Unable to load page"
        errorLabel.textColor = .secondaryLabel
        errorLabel.font = .systemFont(ofSize: 16, weight: .medium)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Helper Extension
extension UIViewController {
    var isModal: Bool {
        return presentingViewController != nil ||
               navigationController?.presentingViewController?.presentedViewController == navigationController
    }
}

