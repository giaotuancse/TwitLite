//
//  NewTweetViewController.swift
//  TwitLite
//
//  Created by Giao Tuan on 11/27/15.
//  Copyright © 2015 LiFish. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

@objc protocol NewTweetViewControllerDelegate {
    optional func newTweetViewController(newTweetViewController: NewTweetViewController, didUpdateTweet newTweet: Tweet)
}

class NewTweetViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var exitImageView: UIImageView!
    @IBOutlet weak var contentTextView: KMPlaceholderTextView!
    @IBOutlet weak var bottomControlView: UIView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var limitCharLabel: UILabel!

    weak var delegate: NewTweetViewControllerDelegate?
    var isReply: Bool!
    var currentTweet: Tweet?
    
    @IBOutlet weak var bottomControlConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(isReply)
        if isReply == true {
            contentTextView.placeholder = "Reply to \((currentTweet?.user?.name)! as String)"
        }
        
        // handle action on exit image clicked
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped"))
        exitImageView.userInteractionEnabled = true
        exitImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // listener for keyboard show/hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("putBottomControlToTop:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("putBottomControlToBottom"), name:UIKeyboardWillHideNotification, object: nil)
        // open keyboard
        contentTextView.becomeFirstResponder()
        contentTextView.delegate = self
        // Do any additional setup after loading the view.
        avatarImageView.setImageWithURL((User.currentUser?.profileImageURL!)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func imageTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func putBottomControlToTop(notification: NSNotification) {
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomControlConstraint.constant = keyboardFrame.size.height
        })
    }
    
    func putBottomControlToBottom() {
        
        UIView.animateWithDuration(0.3, animations: { (   ) -> Void in
            self.bottomControlConstraint.constant = 0
        })
    }
    
    func textViewDidChange(textView: UITextView) {
        let remain = 140 - (textView.text?.characters.count)!
        self.limitCharLabel.text = "\(remain)"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
                let currentCharacterCount = textView.text?.characters.count ?? 0
                if (range.length + range.location > currentCharacterCount){
                    return false
                }
                let newLength = currentCharacterCount + text.characters.count - range.length
                return newLength <= 140
    }

    @IBAction func onTweetClicked(sender: UIButton) {
        let status = self.contentTextView.text!
        if isReply == true {
            TwitterClient.sharedInstance.replyTweet(status, id: (currentTweet?.idString)!, completion: { (tweet, error) -> () in
                if tweet != nil {
                    print("reply sucess")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    
                }
            })
        } else {
            TwitterClient.sharedInstance.updateNewTweet(status) { (tweet, error) -> () in
                if tweet != nil {
                    self.delegate?.newTweetViewController!(self, didUpdateTweet: tweet!)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    
                }
            }
        }
       
    }
}
