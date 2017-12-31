//
//  AgreementController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

enum AgreementStatus {
    case terms
    case policy
}

enum ControllerStatus {
    case authController
    case tabController
}

class AgreementController: UIViewController {
    
    var controllerStatus = ControllerStatus.authController
    var agreementStatus = AgreementStatus.terms
    
    let agreementWebView : UIWebView = {
        let webView = UIWebView()
        
        webView.backgroundColor = .clear
        webView.contentMode = .scaleToFill
        webView.scalesPageToFit = true
        webView.isOpaque = false
        webView.gapBetweenPages = 0
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        handleLoadingWebView()
    }

}

//MARK: handle webview Delegate

extension AgreementController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        for subview: UIView in webView.scrollView.subviews {
            
            print("subview description--", subview.description)
            
            subview.layer.shadowOpacity = 0
            if subview.isKind(of: UIImageView.self) {
                subview.isHidden = true
            }
            for subSubView in subview.subviews {
                
                print("subSubView description--", subSubView.description)
                
                subSubView.layer.shadowOpacity = 0
                if subSubView.isKind(of: UIImageView.self) {
                    subSubView.isHidden = true
                }
            }
            
        }
        
    }
    
    
    
    func getAllSubViewsOfView(v: UIView) -> [UIView] {
        var viewArr = [UIView]()
        for subView in v.subviews {
            viewArr += getAllSubViewsOfView(v: subView)
            viewArr.append(subView)
        }
        return viewArr
    }
    
}

//MARK: handle webview loading

extension AgreementController {
    
    fileprivate func handleLoadingWebView() {
        
        var pdfStr: String?
        
        if agreementStatus == .terms {
            pdfStr = Bundle.main.path(forResource: "termsofservice", ofType: ".pdf")
        } else {
            pdfStr = Bundle.main.path(forResource: "privacypolicy", ofType: ".pdf")
        }
        
        
        
        if let url = URL(string: pdfStr!) {
            
            print("loading pdf")
            let request = URLRequest(url: url)
            self.agreementWebView.loadRequest(request)
        }
    }
    
}

//MARK: Setup views

extension AgreementController {
    
    fileprivate func setupViews() {
        
        setupAgreementWebView()
        setupNavigationBarAndBackground()
    }
    
    private func setupAgreementWebView() {
        
        view.addSubview(agreementWebView)
        
        agreementWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        agreementWebView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        agreementWebView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        agreementWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        agreementWebView.delegate = self
    }
    
    private func setupNavigationBarAndBackground() {
        view.backgroundColor = .white
        
        let dismissButton = UIButton(type: .system)
        let dismissImage = UIImage(named: AssetName.dismissX.rawValue)
        dismissButton.setImage(dismissImage, for: .normal)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        dismissButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        
        agreementWebView.addSubview(dismissButton)

        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        
    }
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
}


