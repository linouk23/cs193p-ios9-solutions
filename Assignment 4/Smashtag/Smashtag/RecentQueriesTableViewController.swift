//
//  RecentQueriesTableViewController.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/20/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

import UIKit

class RecentsQueriesTableViewController: UITableViewController {
    
    // MARK: Model
    
    var recentQueries: [String] {
        return RecentQueries.queries
    }
    
    // MARK: View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }
    
    private struct Storyboard {
        private static let RecentCell = "Recent Cell"
        private static let TweetsSegue = "show recent tweets"
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
        }
    }
}
