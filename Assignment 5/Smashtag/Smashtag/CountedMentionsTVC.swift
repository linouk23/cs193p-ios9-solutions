//
//  CountedMentionsTVC.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/23/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit
import CoreData

class CountedMentionsTVC: CoreDataTableViewController {
    var mention: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        if let context = managedObjectContext where mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "Mention")
            request.predicate = NSPredicate(format: "count > %@ AND query =[cd] %@", NSNumber(integer: 1), mention!)
            
            let sortDescriptor1 = NSSortDescriptor(
                key: "count",
                ascending: false
            )
            let sortDescriptor2 = NSSortDescriptor(
                key: "text",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare(_:))
            )
            
            request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
        } else {
            fetchedResultsController = nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CountedMentionCellIdentifier, forIndexPath: indexPath)
        
        if let mention = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
            var keyword: String?
            var numberOfTweets: Int?
            mention.managedObjectContext?.performBlockAndWait {
                keyword = mention.text
                numberOfTweets = mention.count?.integerValue
            }
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "tweets.count: " + String(numberOfTweets!)
        }
        
        return cell
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let CountedMentionCellIdentifier = "CountedMention Cell"
    }
}
