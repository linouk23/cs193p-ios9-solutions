//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/20/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {
    
    // MARK: Model
    
    private var mentions = [Mentions]()
    
    private struct Mentions: CustomStringConvertible
    {
        var title: String
        var data: [MentionItem]
        var description: String { return "\(title): \(data)" }
    }
    
    private enum MentionItem: CustomStringConvertible
    {
        case Keyword(String)
        case Image(NSURL, Double)
        var description: String {
            switch self {
            // For hashtags, urls and user screen names
            case .Keyword(let keyword): return keyword
            // For images
            case .Image(let url, _): return url.path ?? ""
            }
        }
    }
    
    var tweet: Twitter.Tweet? {
        didSet {
            // Transform Tweet into internal data structure [Mentions]
            title = tweet?.user.screenName
            if let media = tweet?.media where !media.isEmpty {
                mentions.append(Mentions(title: Title.images,
                    data: media.map { MentionItem.Image($0.url, $0.aspectRatio) }))
            }
            if let urls = tweet?.urls where !urls.isEmpty{
                mentions.append(Mentions(title: Title.urls,
                    data: urls.map { MentionItem.Keyword($0.keyword) }))
            }
            if let hashtags = tweet?.hashtags where !hashtags.isEmpty{
                mentions.append(Mentions(title: Title.hashtags,
                    data: hashtags.map { MentionItem.Keyword($0.keyword) }))
            }
            if let users = tweet?.userMentions where !users.isEmpty{
                mentions.append(Mentions(title: Title.users,
                    data: users.map { MentionItem.Keyword($0.keyword) }))
            }
        }
    }
    
    private struct Title {
        static let images = "Images"
        static let urls = "URLs"
        static let hashtags = "Hashtags"
        static let users = "Users"
    }
    
    private struct Storyboard {
        static let KeywordCellIdentifier = "Keyword Cell"
        static let KeywordSegue = "from keyword"
        static let ImageCellIdentifier = "Image Cell"
        static let ImageSegue = "show image"
        static let SafariSegue = "show url"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.KeywordCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = keyword
            return cell
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageUrl = url
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.KeywordSegue {
                if let ttvc = segue.destinationViewController as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    let text = cell.textLabel?.text {
                    ttvc.searchText = text
                }
            } else if identifier == Storyboard.ImageSegue {
                if let ivc = segue.destinationViewController as? ImageViewController,
                    let cell = sender as? ImageTableViewCell {
                    
                    ivc.imageURL = cell.imageUrl
                    ivc.title = title
                    
                }
            }
        }
    }
    
    // We don't want to perform a segue for URL as for a .Keyword
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == Storyboard.KeywordSegue {
            if let cell = sender as? UITableViewCell,
                let indexPath =  tableView.indexPathForCell(cell),
                let url = cell.textLabel?.text
                where mentions[indexPath.section].title == Title.urls {
                if url.hasPrefix("http") {
                    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                    return false
                }
            }
        }
        return true
    }
}
