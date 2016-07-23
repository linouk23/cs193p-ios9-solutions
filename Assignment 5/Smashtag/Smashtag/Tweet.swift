//
//  Tweet.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/23/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Tweet: NSManagedObject {

    class func tweetWithTwitterInfo(keyword: String, twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet?
    {
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
            return addMentions(keyword, tweet: tweet, twitterInfo: twitterInfo, inManagedObjectContext: context)
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet {
            tweet.text = twitterInfo.text
            tweet.unique = twitterInfo.id
            tweet.posted = twitterInfo.created
            return addMentions(keyword, tweet: tweet, twitterInfo: twitterInfo, inManagedObjectContext: context)
        }
        return nil
    }
    
    class func addMentions(keyword: String, tweet: Tweet, twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet {
        let tweetMentions = ["hashtags": twitterInfo.hashtags,
                             "userMentions": twitterInfo.userMentions]
        for (_, mentionsInfo) in tweetMentions {
            for mentionInfo in mentionsInfo {
                if let mention = Mention.mentionWithMentionInfo(keyword, mentionInfo: mentionInfo, inManagedObjectContext: context) {
                    let mentions = tweet.mutableSetValueForKey("mentions")
                    mentions.addObject(mention)
                }
            }
        }
        return tweet
    }
}
