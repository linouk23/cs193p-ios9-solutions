//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/20/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    // MARK: Model
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            guard let text = searchText where !text.isEmpty else {
                return
            }
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
            RecentQueries.add(text)
        }
    }
    
    // MARK: Fetching Tweets
    
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: Constants.numberOfTweets)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets()
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let MentionsSegueIdentifier = "show mentions"
    }
    
    private struct Constants {
        static let numberOfTweets = 100
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.MentionsSegueIdentifier {
                if let mtvc = segue.destinationViewController as? MentionsTableViewController {
                    if let cell = sender as? TweetTableViewCell {
                        mtvc.tweet = cell.tweet
                    }
                }
            }
        }
    }
    
    private func needUpdate(tweet: Tweet) -> Bool {
        return !tweet.media.isEmpty || !tweet.hashtags.isEmpty || !tweet.userMentions.isEmpty || !tweet.urls.isEmpty
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == Storyboard.MentionsSegueIdentifier {
            if let cell = sender as? TweetTableViewCell {
                return needUpdate(cell.tweet!)
            }
        }
        return false
    }
}
