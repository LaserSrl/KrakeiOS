//
//  DisplayPathCache.swift
//  OrchardGen
//
//  Created by Patrick on 03/09/15.
//  Copyright © 2015 Dream Team. All rights reserved.
//

import Foundation
import CoreData

@objc(DisplayPathCache)
open class DisplayPathCache: NSManagedObject{
    @NSManaged open var date: Date!
    @NSManaged open var displayPath: String!
    @NSManaged open var cacheItems: NSOrderedSet!
    @NSManaged open var extrasParameters: NSDictionary!
    
    public static func fetchPredicateForID(_ cacheID: NSManagedObjectID?) -> NSPredicate {
        if cacheID != nil {
            return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "caches"), rightExpression: NSExpression(forConstantValue: cacheID), modifier: NSComparisonPredicate.Modifier.any, type: NSComparisonPredicate.Operator.equalTo, options: NSComparisonPredicate.Options.caseInsensitive)
        }
        return NSPredicate(value: false)
    }

    @objc(addCacheItemsObject:)
    @NSManaged public func addToCacheItems(_ value: ManagedMappedContentItem)

    @objc(removeCacheItemsObject:)
    @NSManaged public func removeFromCacheItems(_ value: ManagedMappedContentItem)

    @objc(addCacheItems:)
    @NSManaged public func addToCacheItems(_ values: NSOrderedSet)

    @objc(removeCacheItems:)
    @NSManaged public func removeFromCacheItems(_ values: NSOrderedSet);
}
