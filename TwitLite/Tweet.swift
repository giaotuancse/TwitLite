//
//  Tweet.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/24/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import Foundation

class Tweet : NSObject {
    var user: User?
    var text: String?
    var createAtString : String?
    var createAt : NSDate?
    var friendlyTime: String?
    var isRetweetFromOther = false
    var reTweet: Tweet?
    var retweetCount: Int!
    var favoriteCount: Int!
    var isRetweeted = false
    var isFavorited = false
    var idString: String?
    var rootTweetID: String?
    
    init(dictionary : NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createAtString = dictionary["created_at"] as? String
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createAt = formatter.dateFromString(createAtString!)
        friendlyTime = DateTimeUtils.timeAgoSince(createAt!)
        let reTweetDic = dictionary["retweeted_status"] as? NSDictionary
        if reTweetDic == nil {
            reTweet = nil
            isRetweetFromOther = false
        } else {
            reTweet = Tweet(dictionary: reTweetDic!)
            isRetweetFromOther = true
        }
        retweetCount = dictionary["retweet_count"] as? Int! ?? 0
        favoriteCount = dictionary["favorite_count"] as? Int! ?? 0
        
        isRetweeted = (dictionary["retweeted"] as? Bool!)!
        isFavorited = (dictionary["favorited"] as? Bool!)!
        idString = (dictionary["id_str"] as? String)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dict in array {
            tweets.append(Tweet(dictionary: dict))
        }
        return tweets
    }
}
