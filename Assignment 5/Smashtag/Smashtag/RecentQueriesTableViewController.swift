//
//  RecentQueriesTableViewController.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/20/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit
import CoreData

class RecentsQueriesTableViewController: UITableViewController {
    
    // MARK: Model
    
    var recentQueries: [String] {
        return RecentQueries.queries
    }
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    // MARK: View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }
    
    private struct Storyboard {
        static let RecentCell = "Recent Cell"
        static let TweetsSegue = "show recent tweets"
        static let CountedMentionsSegue = "show counted mentions"
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentQueries.count
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.RecentCell,
                                                               forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = recentQueries[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                                               forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            RecentQueries.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier where identifier == Storyboard.TweetsSegue,
            let cell = sender as? UITableViewCell,
            let ttvc = segue.destinationViewController as? TweetTableViewController {
            ttvc.searchText = cell.textLabel?.text
        } else if let identifier = segue.identifier where identifier == Storyboard.CountedMentionsSegue,
            let cmtvc = segue.destinationViewController as? CountedMentionsTVC,
           let sender = sender as? NSIndexPath {
            cmtvc.mention = recentQueries[sender.row]
            cmtvc.managedObjectContext = managedObjectContext
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.CountedMentionsSegue, sender: indexPath)
    }
}
