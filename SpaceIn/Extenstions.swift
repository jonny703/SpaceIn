//
//  Extenstions.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.sync {
                
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: (urlString as AnyObject) as! NSString)
                    self.image = downloadedImage
                    
                }
                
                
            }
            
        }).resume()
        
        
    }
    
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
        
    }
    
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIViewController {
    
//    func findBestViewController(vc: UIViewController) -> UIViewController {
//        
//        if (vc.presentedViewController != nil) {
//            return self.findBestViewController(vc: vc.presentedViewController!)
//        } else if vc.isKind(of: UISplitViewController.self) {
//            
//            let svc = UISplitViewController()
//            if svc.viewControllers.count > 0 {
//                return self.findBestViewController(vc: svc.viewControllers.last!)
//            } else {
//                return vc
//            }
//            
//        } else if vc.isKind(of: UINavigationController.self) {
//            let nvc = UINavigationController()
//            if nvc.viewControllers.count > 0 {
//                return self.findBestViewController(vc: nvc.topViewController!)
//            } else {
//                return vc
//            }
//            
//        } else if vc.isKind(of: UITabBarController.self) {
//            let tvc = UITabBarController()
//            if (tvc.viewControllers?.count)! > 0 {
//                return self.findBestViewController(vc: tvc.selectedViewController!)
//            } else {
//                return vc
//            }
//        } else {
//            return vc
//        }
//        
//        
//    }
//    
//    func currentViewController() -> UIViewController {
//        let viewController = UIApplication.shared.keyWindow?.rootViewController
//        return self.findBestViewController(vc: viewController!)
//    }
    
}

func findBestViewController(vc: UIViewController) -> UIViewController {
    
    if (vc.presentedViewController != nil) {
        return findBestViewController(vc: vc.presentedViewController!)
    } else if vc.isKind(of: UISplitViewController.self) {
        
        let svc = UISplitViewController()
        if svc.viewControllers.count > 0 {
            return findBestViewController(vc: svc.viewControllers.last!)
        } else {
            return vc
        }
        
    } else if vc.isKind(of: UINavigationController.self) {
        let nvc = UINavigationController()
        if nvc.viewControllers.count > 0 {
            return findBestViewController(vc: nvc.topViewController!)
        } else {
            return vc
        }
        
    } else if vc.isKind(of: UITabBarController.self) {
        let tvc = UITabBarController()
        if (tvc.viewControllers?.count)! > 0 {
            return findBestViewController(vc: tvc.selectedViewController!)
        } else {
            return vc
        }
    } else {
        return vc
    }
    
    
}

func currentViewController() -> UIViewController? {
    if let viewController = UIApplication.shared.keyWindow?.rootViewController {
        let returnController = findBestViewController(vc: viewController)
        return returnController
    } else {
        return nil
    }
    
}











