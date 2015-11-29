//
//  DetailViewController.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/27/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  
    @IBOutlet weak var topHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var retweetUsernameLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetCountlabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    var currentTweet : Tweet!
    var newTweetID: String!
    let uiHelper = UIHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInitView() {
        if currentTweet.isRetweeted {
            retweetButton.setImage(UIImage(named: "retweeted"), forState: .Normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet"), forState: .Normal)
        }
        if currentTweet.isFavorited {
            favouriteButton.setImage(UIImage(named: "loved"), forState: .Normal)
        } else {
            favouriteButton.setImage(UIImage(named: "love"), forState: .Normal)
        }
        if currentTweet.isRetweetFromOther {
            let curReTweet = currentTweet.reTweet!
            screenNameLabel.text = curReTweet.user?.name
            usernameLabel.text = "@\((curReTweet.user?.screenName)! as String)"
            contentLabel.text = curReTweet.text
            dateLabel.text = DateTimeUtils.getFullDate(currentTweet.createAt!)
            avatarImage.setImageWithURL((curReTweet.user?.profileImageURL)!)
            let countRetweet = "<b>\(curReTweet.retweetCount)</b> RETWEETS, <b>\(curReTweet.favoriteCount)</b> LIKES"
            UIHelper.setTextAtributted(retweetCountlabel,inputText: countRetweet)
            retweetUsernameLabel.text = "@\((currentTweet.user!.screenName)! as String) Retweeted"
        } else {
            screenNameLabel.text = currentTweet.user?.screenName
            usernameLabel.text = "@\((currentTweet.user?.screenName)! as String)"
            contentLabel.text = currentTweet.text
            dateLabel.text = DateTimeUtils.getFullDate(currentTweet.createAt!)
            avatarImage.setImageWithURL((currentTweet.user?.profileImageURL)!)
            let countRetweet = "<b>\(currentTweet.retweetCount)</b> RETWEETS, <b>\(currentTweet.favoriteCount)</b> LIKES"
            UIHelper.setTextAtributted(retweetCountlabel,inputText: countRetweet)
            topHeightContraint.constant = 0

        }

    }

    @IBAction func onRetweetToggle(sender: UIButton) {
        if currentTweet.isRetweeted {
            print("do unRe")
            if newTweetID == nil {
                let rootID : String!
                if self.currentTweet.isRetweetFromOther {
                    rootID = currentTweet.reTweet?.idString
                } else {
                    rootID = currentTweet.idString
                }
                TwitterClient.sharedInstance.getHomeRetweetedId(rootID, completion: { (retweetedId, error) -> () in
                    if retweetedId != nil {
                        TwitterClient.sharedInstance.unRetweet(retweetedId!, completion: { (tweet, error) -> () in
                            if tweet != nil {
                                print("Change retweet to unre")
                                self.currentTweet.isRetweeted = false
                                self.retweetButton.setImage(UIImage(named: "retweet"), forState: .Normal)
                                self.uiHelper.setNewCountRetweet(self.retweetCountlabel, valueInc: -1, tweet: self.currentTweet)
                                self.currentTweet.retweetCount = self.currentTweet.retweetCount - 1
                            } else {
                                print("Error get home id")
                            }
                        })
                    } else {
                        print("error unre")
                    }
                })
            } else {
                TwitterClient.sharedInstance.unRetweet(self.newTweetID as String!, completion: { (tweet, error) -> () in
                    if tweet != nil {
                        print("Change retweet to unre")
                        self.currentTweet.isRetweeted = false
                        self.retweetButton.setImage(UIImage(named: "retweet"), forState: .Normal)
                        self.uiHelper.setNewCountRetweet(self.retweetCountlabel, valueInc: -1, tweet: self.currentTweet)
                        self.currentTweet.retweetCount = self.currentTweet.retweetCount - 1
                    } else {
                        print("Error get home id")
                    }
                })
            }
            
        } else {
            TwitterClient.sharedInstance.retweet(currentTweet.idString as String!, completion: { (tweet, error) -> () in
                if tweet != nil {
                    self.currentTweet.isRetweeted = true
                    self.newTweetID = tweet?.idString
                    self.retweetButton.setImage(UIImage(named: "retweeted"), forState: .Normal)
                    self.uiHelper.setNewCountRetweet(self.retweetCountlabel, valueInc: 1, tweet: self.currentTweet)
                    self.currentTweet.retweetCount = self.currentTweet.retweetCount + 1
                } else {
                    
                }
            })
        }
    }
    
    @IBAction func onFavouriteToggle(sender: UIButton) {
        if currentTweet.isFavorited {
            TwitterClient.sharedInstance.unFavourite(currentTweet.idString!, completion: { (tweet, error) -> () in
                if tweet != nil {
                    print("unfav success")
                     self.currentTweet.isFavorited = false
                    self.favouriteButton.setImage(UIImage(named: "love"), forState: .Normal)
                    self.uiHelper.setNewCountFavourite(self.retweetCountlabel, valueInc: -1, tweet: self.currentTweet)
                    self.currentTweet.favoriteCount = self.currentTweet.favoriteCount - 1
                } else {
                    
                }
            })
        } else {
            TwitterClient.sharedInstance.favourite(currentTweet.idString!, completion: { (tweet, error) -> () in
                if tweet != nil {
                    print("fav success")
                    self.currentTweet.isFavorited = true
                    self.favouriteButton.setImage(UIImage(named: "loved"), forState: .Normal)
                    self.uiHelper.setNewCountFavourite(self.retweetCountlabel, valueInc: 1, tweet: self.currentTweet)
                    self.currentTweet.favoriteCount = self.currentTweet.favoriteCount + 1

                } else {
                    
                }
            })
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController
        if navigationController is NewTweetViewController {
            let newTweetViewController = navigationController as! NewTweetViewController
            newTweetViewController.isReply = true
            newTweetViewController.currentTweet = currentTweet
        }
    }


}
