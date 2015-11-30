//
//  TwitterClient.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/23/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "zmj0IBBhT5cZl9cbFnEljhjIp"
let twitterConsumerSecret = "8IzkQvVcILw2mSM49WlHmZejidn9LNZ9OzYrpIEJqTc5tmAfwm"
let twitterBaseURL = NSURL(string : "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance : TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey:
                twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitlite://oauth"), scope: nil, success: { (requestToken :BDBOAuth1Credential!) -> Void in
            print("got request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }) { (error :NSError!) -> Void in
                print(error)
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken : BDBOAuth1Credential!) -> Void in
            print("access succes")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken!)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation : AFHTTPRequestOperation, response : AnyObject) -> Void in
                // print("user", response)
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation : AFHTTPRequestOperation?, error : NSError) -> Void in
                    print("error user", error   )
            })
            }) { (error : NSError!) -> Void in
                print("Error access", error)
                self.loginCompletion?(user: nil, error: error)
        }
    }

    // Fetch timeline posts
    func fecthTimeline(completion: (tweet: [Tweet]?, error: NSError? ) ->()) {
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tw = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweet: tw, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweet: nil, error: error)
                print("Error fetch timeline", error)
        }
    }
    
    // Update new tweet
    func updateNewTweet(status: String, completion:(tweet: Tweet?, error: NSError?) -> ()){
        var params = [String : AnyObject]()
        params["status"] = status
        
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweet: nil, error: error)
                print("Update Tweet error",error)
        }
    }
    // retweet
    func retweet(id: String, completion:(tweet: Tweet?, error: NSError?) -> ()){
       let request = "1.1/statuses/retweet/\(id).json"
        TwitterClient.sharedInstance.POST(request, parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            print("Retweet successfull")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweet: nil, error: error)
                print("Retweet error",error)
        }
    }
    
    func unRetweet(id: String, completion:(tweet: Tweet?, error: NSError?) -> ()){
        print("unretweetID",id)
        let request = "1.1/statuses/destroy/\(id).json"
        TwitterClient.sharedInstance.POST(request, parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            print("UNRetweet successfull")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweet: nil, error: error)
                print("UNRetweet error",error)
        }
    }
    
    // favourite
    func favourite(id: String, completion:(tweet: Tweet?, error: NSError?) -> ()){
        var params = [String : AnyObject]()
        params["id"] = id

        TwitterClient.sharedInstance.POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            print("favourite successfull")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweet: nil, error: error)
                print("favourite error",error)
        }
    }
    func unFavourite(id: String, completion:(tweet: Tweet?, error: NSError?) -> ()){
        var params = [String : AnyObject]()
        params["id"] = id
        
        TwitterClient.sharedInstance.POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            print("unFavourite successfull")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweet: nil, error: error)
                print("unFavourite error",error)
        }
    }
    
    func getHomeRetweetedId(id: String, completion: (retweetedId: String?, error: NSError?) -> ()) {
        var params = [String : AnyObject]()
        params["include_my_retweet"] = true
        print("gethomeretweet", id)
        TwitterClient.sharedInstance.GET("1.1/statuses/show/\(id).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let dict = response as! NSDictionary
            let homeId = (dict.valueForKeyPath("current_user_retweet.id_str") as? String)!
             print("gethomeretweet success", homeId)
            completion(retweetedId: homeId, error: nil)
            
            }){ (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(retweetedId: nil, error: error)
                print("get Homeretweet error",error)
        }
    }
    
    func replyTweet(text: String, id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = [String : AnyObject]()
        params["status"] = text
        params["in_reply_to_status_id"] = id
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: params, success: { (peration: AFHTTPRequestOperation, response: AnyObject) -> Void in
                print("reply success")
                let newTweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: newTweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                print("error reply", error)
                completion(tweet: nil, error: error)
        }
    }
}
