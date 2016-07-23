//
//  Mention.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/23/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Mention: NSManagedObject {

    class func mentionWithMentionInfo(keyword: String, mentionInfo: Twitter.Mention, inManagedObjectContext context: NSManagedObjectContext) -> Mention?
    {
        let request = NSFetchRequest(entityName: "Mention")
        request.predicate = NSPredicate(format: "text =[cd] %@ AND query = %@", mentionInfo.keyword, keyword)
        
        if let mention = (try? context.executeFetchRequest(request))?.first as? Mention {
            mention.count = NSNumber(int: mention.count!.intValue + 1)
            return mention
        } else if let mention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
            mention.text = mentionInfo.keyword.lowercaseString
            mention.count = 1
            mention.query = keyword
            return mention
        }
        return nil
    }
}
