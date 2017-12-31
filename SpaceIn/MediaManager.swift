//
//  MediaManager.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

enum CameraPermissionStatus {
    case notAsked
    case denied
    case accepted
    case restricted
}


class MediaManager {
    static let shared = MediaManager()
    static func setup() {
        let _ = MediaManager.shared
    }
    
    public func cameraPermissionStatus() -> CameraPermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status {
        case .notDetermined:
            return CameraPermissionStatus.notAsked
        case .authorized:
            return CameraPermissionStatus.accepted
        case .denied:
            return CameraPermissionStatus.denied
        case .restricted:
            return CameraPermissionStatus.restricted
        }
    }
    
    
    public func cameraRollPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    init() {
    }
}
