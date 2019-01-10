//
//  ManagedMappedContentItem.swift
//  OrchardGen
//
//  Created by Patrick on 03/09/15.
//  Copyright © 2015 Dream Team. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedMappedContentItem)
open class ManagedMappedContentItem: NSManagedObject {
    @NSManaged open var identifier: NSNumber!
    @NSManaged open var stringIdentifier: String!
    @NSManaged open var caches: NSSet!
    
}
