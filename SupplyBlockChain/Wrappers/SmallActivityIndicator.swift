//
//  SmallActivityIndicator.swift
//  SupplyBlockChain
//
//  Created by Dave on 3/30/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class SmallActivityIndicator {
    
    // Need to make this class a singleton in order for
    // the same views to be added and removed each time
    //
    static let shared = SmallActivityIndicator()
    
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Show customized activity indicator,
    // actually add activity indicator to passing view
    // @param uiView - add activity indicator to this view
    //
    func showActivityIndicator(uiView: UIView) {
        uiView.isUserInteractionEnabled = false
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        // Adjust the placement of the indicator here
        //
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.darkGray
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.width / 2, y: loadingView.frame.height / 2)
        activityIndicator.hidesWhenStopped = true
        
        DispatchQueue.main.async {
            self.loadingView.addSubview(self.activityIndicator)
            uiView.addSubview(self.loadingView)
            self.activityIndicator.startAnimating()
        }
    }
    
    // Hide activity indicator
    // Actually remove activity indicator from its super view
    // @param uiView - remove activity indicator from this view
    //
    func hideActivityIndicator(uiView: UIView) {
        // check to make sure container is a subview before we
        // remove it
        if loadingView.isDescendant(of: uiView) {
            DispatchQueue.main.async {
                uiView.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                self.loadingView.removeFromSuperview()
            }
        }
    }
}

