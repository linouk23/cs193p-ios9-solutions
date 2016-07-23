//
//  RecentQueries.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/20/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import Foundation

struct RecentQueries
{
    private static let defaults = NSUserDefaults.standardUserDefaults()
    private struct Constants {
        static let key = "RecentQueries"
        static let limit = 100
    }
    
    static var queries: [String] {
        return (defaults.objectForKey(Constants.key) as? [String]) ?? []
    }
    
    static func add(term: String) {
        var newArray = queries.filter({ term.caseInsensitiveCompare($0) != .OrderedSame })
        newArray.insert(term, atIndex: 0)
        while newArray.count > Constants.limit {
            newArray.removeLast()
        }
        defaults.setObject(newArray, forKey: Constants.key)
    }
    
    static func removeAtIndex(index: Int) {
        var currentQueries = (defaults.objectForKey(Constants.key) as? [String]) ?? []
        currentQueries.removeAtIndex(index)
        defaults.setObject(currentQueries, forKey: Constants.key)
    }
}
