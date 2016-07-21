//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/20/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    // MARK: Outlets
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    // MARK: Model
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.attributedText  = getColorfulTextLabel(tweet)
            tweetScreenNameLabel?.text = "\(tweet.user)"
            setProfileImageView(tweet)
            tweetCreatedLabel?.text = getCreatedLabel(tweet)
        }
    }
    
    private struct Color {
        static let user = UIColor.purpleColor()
        static let hashtag = UIColor.darkGrayColor()
        static let url = UIColor.blueColor()
    }
    
    private func getColorfulTextLabel(tweet: Tweet) -> NSMutableAttributedString {
        var text = tweet.text
        for _ in tweet.media {
            text += " 📷"
        }
        
        // Enhance Smashtag from lecture to highlight (in a different color for each) hashtags,
        // urls and user screen names mentioned in the text of each Tweet
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.setMensionsColor(tweet.hashtags, color: Color.hashtag)
        attributedText.setMensionsColor(tweet.urls, color: Color.url)
        attributedText.setMensionsColor(tweet.userMentions, color: Color.user)
        
        return attributedText
    }
    
    private func setProfileImageView(tweet: Tweet) {
        guard let profileImageURL = tweet.user.profileImageURL else {
            return
        }
        
        // NSData(contentsOfURL:) blocks the thread it is called from when invoked with a network url.
        // Thus we cannot call it from the main thread.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let loadedImageData = NSData(contentsOfURL: profileImageURL)
            dispatch_async(dispatch_get_main_queue()) {
                if profileImageURL == tweet.user.profileImageURL {
                    if let imageData = loadedImageData  {
                        self.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }

    private func getCreatedLabel(tweet: Tweet) -> String {
        let formatter = NSDateFormatter()
        if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        } else {
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        return formatter.stringFromDate(tweet.created)
    }
}

private extension NSMutableAttributedString {
    func setMensionsColor(mensions: [Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
