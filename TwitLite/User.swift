//
//  User.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/24/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import Foundation

var _currentUser: User?
let USER_KEY = "USER_KEY"

class User : NSObject {
    var name : String?
    var screenName : String?
    var profileImageURL : NSURL!
    var tagline : String?
    var dictionary : NSDictionary
    
    init(dictionary : NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        profileImageURL = NSURL(string: (dictionary["profile_image_url"] as? String ?? "")!)
        tagline = dictionary["description"]  as? String
        
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
            let data = NSUserDefaults.standardUserDefaults().objectForKey(USER_KEY)
                if data != nil {
                    do {
                    let dict = try NSJSONSerialization.JSONObjectWithData(data! as! NSData, options: [])
                        _currentUser = User(dictionary: dict as! NSDictionary)
                    } catch {
                        print(error)
                        return _currentUser
                    }
        
                }
            }
            return _currentUser
        }
        set (user) {
            _currentUser = user
            
            if _currentUser != nil {
                // save to NSDefault
                do {
                   let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                   NSUserDefaults.standardUserDefaults().setObject(data, forKey: USER_KEY)
                } catch let error as NSError {
                    print(error)
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: USER_KEY)
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: USER_KEY)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName("user log out", object: nil)
    }

}