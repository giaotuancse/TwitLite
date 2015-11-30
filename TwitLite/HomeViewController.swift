//
//  HomeViewController.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/25/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import UIKit
import Cartography
import Darwin

class HomeViewController: UIViewController, NewTweetViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var tweetList = [Tweet]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden  = false;
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        refreshData()
        // Refresh UI
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)

    }
    func refreshData() {
        //load data
        TwitterClient.sharedInstance.fecthTimeline { (tweet, error) -> () in
            self.refreshControl.endRefreshing()
            if tweet != nil {
                print(tweet?.count)
                self.tweetList = tweet!
                self.tableView.reloadData()
            }
        }

    }
    @IBAction func logoutClicked(sender: UIBarButtonItem) {
        User.currentUser?.logout()
        exit(0)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let navigationController = segue.destinationViewController as? NewTweetViewController {
            navigationController.delegate = self
             navigationController.isReply = false
        } else if let navigationController = segue.destinationViewController as? DetailViewController{
            var indexPath: AnyObject!
            indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            navigationController.currentTweet = tweetList[indexPath!.row]
        }
    }
    
    func newTweetViewController(newTweetViewController: NewTweetViewController, didUpdateTweet newTweet: Tweet) {
        tweetList.insert(newTweet, atIndex: 0)
        tableView.reloadData()
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetCell2
        let curItem = tweetList[indexPath.row]
        // Set suitable icons for retweet button and favorite button
        if curItem.isRetweeted {
            cell.retweetButton.setImage(UIImage(named: "retweeted"), forState: .Normal)
        } else {
            cell.retweetButton.setImage(UIImage(named: "retweet"), forState: .Normal)
        }
        if curItem.isFavorited {
            cell.favouriteButton.setImage(UIImage(named: "loved"), forState: .Normal)
        } else {
            cell.favouriteButton.setImage(UIImage(named: "love"), forState: .Normal)
        }

        if curItem.isRetweetFromOther {
            let curReTweet = curItem.reTweet!
            cell.screenNameLabel.text = curReTweet.user?.name
            cell.usernameLabel.text = "@\((curReTweet.user?.screenName)! as String)"
            cell.contentLabel.text = curReTweet.text
            cell.friendlyTimeLabel.text = curReTweet.friendlyTime
            cell.avatarImageView.setImageWithURL((curReTweet.user?.profileImageURL)!)
            cell.retweetTopView.hidden = false
            cell.retweetNameLabel.hidden = false
            cell.retweetNameLabel.text = "@\((curItem.user!.screenName)! as String) Retweeted"
            cell.counRetweetLabel.text = "\(curReTweet.retweetCount as Int)"
            cell.countFavLabel.text = "\(curReTweet.favoriteCount as Int)"
        } else {
            cell.screenNameLabel.text = curItem.user?.screenName
            cell.usernameLabel.text = "@\((curItem.user?.screenName)! as String)"
            cell.contentLabel.text = curItem.text
            cell.friendlyTimeLabel.text = curItem.friendlyTime
            cell.avatarImageView.setImageWithURL((curItem.user?.profileImageURL)!)
            cell.retweetTopView.hidden = true
            cell.retweetNameLabel.hidden = true
            cell.counRetweetLabel.text = "\(curItem.retweetCount as Int)"
            cell.countFavLabel.text = "\(curItem.favoriteCount as Int)"

        }
        return cell
    }
}
