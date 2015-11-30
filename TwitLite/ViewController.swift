//
//  ViewController.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/23/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {
    @IBAction func onLoginClick(sender: UIButton) {
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user : User?, error : NSError?) in
            if user != nil {
                // perform segue
            self.performSegueWithIdentifier("loginSegue2", sender: self)
            } else {
                //handle login error
            }
        }
    }
}
