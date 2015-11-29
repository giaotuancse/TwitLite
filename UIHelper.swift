//
//  UIHelper.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/27/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import Foundation
import UIKit

public class UIHelper {
    
    public static func setTextAtributted(label: UILabel, inputText: String ) {
        let encodedData = inputText.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            label.attributedText = attributedString
        } catch {
            print(error)
        }
    }
    
    func setNewCountRetweet(label: UILabel, valueInc: Int, tweet: Tweet) {
        
        if tweet.isRetweetFromOther {
            let curReTweet = tweet.reTweet!
            curReTweet.retweetCount = (tweet.retweetCount as Int) + valueInc
            let countRetweet = "<b>\(curReTweet.retweetCount)</b> RETWEETS, <b>\(curReTweet.favoriteCount)</b> LIKES"
            print(countRetweet)
            UIHelper.setTextAtributted(label,inputText: countRetweet)
        } else {
            tweet.retweetCount = (tweet.retweetCount as Int) + valueInc
            let countRetweet = "<b>\(tweet.retweetCount)</b> RETWEETS, <b>\(tweet.favoriteCount)</b> LIKES"
            print(countRetweet)
            UIHelper.setTextAtributted(label,inputText: countRetweet)
        }
    }
    func setNewCountFavourite(label: UILabel, valueInc: Int, tweet: Tweet) {
        
        if tweet.isRetweetFromOther {
            let curReTweet = tweet.reTweet!
            print(tweet.favoriteCount)
            print(curReTweet.favoriteCount)
            curReTweet.favoriteCount = (curReTweet.favoriteCount as Int) + valueInc
            let countRetweet = "<b>\(curReTweet.retweetCount)</b> RETWEETS, <b>\(curReTweet.favoriteCount)</b> LIKES"
            print(countRetweet)
            UIHelper.setTextAtributted(label,inputText: countRetweet)
        } else {
            print(tweet.favoriteCount)
            tweet.favoriteCount = (tweet.favoriteCount as Int) + valueInc
            let countRetweet = "<b>\(tweet.retweetCount)</b> RETWEETS, <b>\(tweet.favoriteCount)</b> LIKES"
            print(countRetweet)
            UIHelper.setTextAtributted(label,inputText: countRetweet)
        }
    }
}