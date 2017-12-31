//
//  TutorialVC.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import MapKit
import NDParallaxIntroView

protocol TutorialVCDelegate {
    func tutorialFinished(tutorialVC: TutorialVC)
}

class TutorialVC : UIViewController {
    var didLoadLocationVC = false
    var delegate: TutorialVCDelegate?
    
    var introView = NDIntroView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupIntroView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = StyleGuideManager.introBackgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if self.didLoadLocationVC == false {
//            self.loadLocationPermissionPage()
//        }
    }
}

//MARK: setup NDintroview

extension TutorialVC: NDIntroViewDelegate {
    fileprivate func setupIntroView() {
        
        let pageContents = [[kNDIntroPageTitle: "", kNDIntroPageDescription: "", kNDIntroPageImageName: AssetName.intro1.rawValue], [kNDIntroPageTitle: "", kNDIntroPageDescription: "", kNDIntroPageImageName: AssetName.intro2.rawValue], [kNDIntroPageTitle: "", kNDIntroPageDescription: "", kNDIntroPageImageName: AssetName.intro3.rawValue], [kNDIntroPageTitle: "", kNDIntroPageDescription: "", kNDIntroPageImageName: AssetName.intro4.rawValue]]
        self.introView = NDIntroView(frame: self.view.frame, parallaxImage: UIImage(named: ""), andData: pageContents)
        self.introView.delegate = self
        
        self.view.addSubview(introView)
        
    }
    
    func launchAppButtonPressed() {
        
        if self.didLoadLocationVC == false {
            self.loadLocationPermissionPage()
        }
        
    }
}

// MARK: - Segues and transitions
extension TutorialVC {
    func loadLocationPermissionPage() {
        let askLocationVC = AskLocationVC()
        askLocationVC.delegate = self
        self.present(askLocationVC, animated: true) { 
            
        }
    }
}

extension TutorialVC: AskLocationVCDelegate {
    func finishedLocationAskingForVc(vc: AskLocationVC) {
        self.delegate?.tutorialFinished(tutorialVC: self)
    }
    
}
    
