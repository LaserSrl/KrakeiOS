
//  Created by Patrick on 23/02/16.
//  Copyright © 2015 Laser Group. All rights reserved.

import Foundation
import CoreData

open class PseudoPathCache: NSObject {
    
    
    static var globalClasses = [String : PseudoPathCache]()
    public private(set) var customCacheId: NSManagedObjectID?
    
    public static func createMissingCaches(_ names:[String])
    {
        for name in names {
            _ = sharedInstance(name)
        }
    }
    
    public static func sharedInstance(_ named: String) -> PseudoPathCache{
        if PseudoPathCache.globalClasses[named] == nil {
            let customCachePath = PseudoPathCache()
            let context = OGLCoreDataMapper.sharedInstance().managedObjectContext
            let className = DisplayPathCache.self.description()
            let request = NSFetchRequest<DisplayPathCache>(entityName: className) as! NSFetchRequest<NSFetchRequestResult>
            request.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "displayPath"), rightExpression: NSExpression(forConstantValue: named), modifier: NSComparisonPredicate.Modifier.direct, type: NSComparisonPredicate.Operator.equalTo, options: NSComparisonPredicate.Options.caseInsensitive)
            do {
                customCachePath.customCacheId = try (context.fetch(request).first as? DisplayPathCache)?.objectID
            }catch{
                
            }
            
            if customCachePath.customCacheId == nil {
                
                let cache = DisplayPathCache(entity: NSEntityDescription.entity(forEntityName: className, in: context)!, insertInto: context)
                cache.displayPath = named
                cache.date = Date.distantFuture
                cache.cacheItems = NSOrderedSet()
                do{
                    try context.save()
                }catch{
                    
                }
                customCachePath.customCacheId = cache.objectID
            }
            PseudoPathCache.globalClasses[named] = customCachePath
        }
        return PseudoPathCache.globalClasses[named]!
    }
    
    open func add(_ object: ManagedMappedContentItem){
        
        let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: customCacheId!) as! DisplayPathCache
        if cache.cacheItems.contains(object) == false {
            cache.addToCacheItems(object)
        }
        do{
            try cache.managedObjectContext!.save()
        }catch{
            
        }
    }
    
    open func remove(_ object: ManagedMappedContentItem){
        
        let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: customCacheId!) as! DisplayPathCache
        if cache.cacheItems.contains(object) == true {
            cache.removeFromCacheItems([object])
        }
        do{
            try cache.managedObjectContext!.save()
        }catch{
            
        }
    }
    
    open func clearList(){
        let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: customCacheId!) as! DisplayPathCache
        cache.removeFromCacheItems(cache.cacheItems)
        
        do{
            try cache.managedObjectContext!.save()
        }catch{
            
        }
    }
    
    open func contains(_ object: ManagedMappedContentItem) -> Bool{
        let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: customCacheId!) as! DisplayPathCache
        return cache.cacheItems.contains(object)
    }
}
