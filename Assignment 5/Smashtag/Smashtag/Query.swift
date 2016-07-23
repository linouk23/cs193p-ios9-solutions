//
//  Query.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/23/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class Query: NSManagedObject {

    class func queryWithQueryInfo(keyword: String, tweetsInfo: [Twitter.Tweet], inManagedObjectContext context: NSManagedObjectContext) -> Query?
    {
        let request = NSFetchRequest(entityName: "Query")
        request.predicate = NSPredicate(format: "keyword = %@", keyword)
        
        if let query = (try? context.executeFetchRequest(request))?.first as? Query {
            return addTweets(query, keyword: keyword, tweetsInfo: tweetsInfo, inManagedObjectContext: context)
        } else if let query = NSEntityDescription.insertNewObjectForEntityForName("Query", inManagedObjectContext: context) as? Query {
            query.keyword = keyword
            return addTweets(query, keyword: keyword, tweetsInfo: tweetsInfo, inManagedObjectContext: context)
        }
        return nil
    }
    
    class func addTweets(query: Query, keyword: String, tweetsInfo: [Twitter.Tweet], inManagedObjectContext context: NSManagedObjectContext) -> Query {
        for tweetInfo in tweetsInfo {
            if let tweet = Tweet.tweetWithTwitterInfo(keyword, twitterInfo: tweetInfo, inManagedObjectContext: context) {
                let tweets = query.mutableSetValueForKey("tweets")
                tweets.addObject(tweet)
            }
        }
        return query
    }
}
