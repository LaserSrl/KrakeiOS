//
//  OGLCoreDataMapper.m
//  OrchardGen
//
//  Created by joel on 21/10/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

@import AFNetworking;
#import <Krake/Krake-Swift.h>
#import "OGLCoreDataMapper_OMPrivateMethods.h"
#import "NSString+OrchardMapping.h"
#import "OGLConfigurations.h"
#import "OGLConstants.h"
#import "NSMutableDictionary+OGLParameters.h"
#import "OMLoadDataTask.h"
#import "OMPrivacyViewController.h"

NSUInteger const OMPrivacyClose_Error_Code = 3450;


@interface OGLCoreDataMapper ()


@property (nonatomic, strong) NSURL *serviceURL;


@end

@implementation OGLCoreDataMapper

static __strong id currentOGLCoreDataMapper_;

+(OGLCoreDataMapper*)sharedInstance
{
    return currentOGLCoreDataMapper_;
}

+(void)setSharedInstance:(OGLCoreDataMapper*)OGLCoreDataMapper
{
    currentOGLCoreDataMapper_ = OGLCoreDataMapper;
}

- (instancetype __nonnull)initWithManagedObjectContext:(NSManagedObjectContext* __nonnull)context model:(NSManagedObjectModel * _Nonnull)model
{
    
    OGLConfigurations *configurations = [[OGLConfigurations alloc] init];
    NSURL *serviceUrl = [KrakePlist path];
    return [self initWithServiceURL:serviceUrl managedObjectContext:context model: model configurations:configurations];
}

- (instancetype)initWithServiceURL:(NSURL *)serviceURL
              managedObjectContext:(NSManagedObjectContext *)context
              model:(NSManagedObjectModel * _Nonnull)model
{
    OGLConfigurations *configurations = [[OGLConfigurations alloc] init];
    
    return [self initWithServiceURL:serviceURL managedObjectContext:context model:model configurations:configurations];
}

- (instancetype)initWithServiceURL:(NSURL *)serviceURL
              managedObjectContext:(NSManagedObjectContext *)context
                                  model:(NSManagedObjectModel * _Nonnull)model
                    configurations:(OGLConfigurations *)configurations
{
    self = [super init];
    if (self) {
        _serviceURL = serviceURL;
        _configurations = configurations;
        _managedObjectContext = context;
        _managedObjectModel = model;
        _defaultCacheTime = 60;
    }
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    return self;
}

- (OMLoadDataTask*)loadDataWithDisplayAlias:(NSString *)displayAlias extras:(NSDictionary *)extrasParameters completionBlock:(OMMapperCompletionBlock)completion
{
    return [self loadDataWithDisplayAlias:displayAlias extras:extrasParameters loginRequired:NO completionBlock:completion];
}

- (OMLoadDataTask*) loadDataWithDisplayAlias:(NSString*)displayAlias extras:(NSDictionary*)extrasParameters loginRequired:(BOOL)isLoginRequired completionBlock:(OMMapperCompletionBlock)completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if(extrasParameters)
        [parameters addEntriesFromDictionary:extrasParameters];
    
    parameters[KParametersKeys.displayAlias] = displayAlias;
    
    return [self loadDataWithCommand:self.configurations.commandGetByAlias
                          parameters:parameters
                       loginRequired:isLoginRequired
                     completionBlock:completion];
}

- (OMLoadDataTask* __nonnull) loadDataWithController:(NSString* __nonnull)controller extras:(NSDictionary* __nullable)extrasParameters loginRequired:(BOOL)isLoginRequired completionBlock:(OMMapperCompletionBlock __nonnull)completion
{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if(extrasParameters)
        [parameters addEntriesFromDictionary:extrasParameters];
    
    parameters[KParametersKeys.displayAlias] = controller;
    
    return [self loadDataWithCommand:controller
                          parameters:parameters
                       loginRequired:isLoginRequired
                     completionBlock:completion];
}

- (OMLoadDataTask*)loadDataWithCommand:(NSString*)command
                            parameters:(NSMutableDictionary*)parameters
                         loginRequired:(BOOL)isLoginRequired
                       completionBlock:(void(^)(id parsedObject, NSError*error,BOOL completed))completion
{
    
    if(!parameters[KParametersKeys.lang])
        parameters[KParametersKeys.lang] = self.configurations.language;
    
    parameters[REQUEST_REAL_FORMAT ] = @"true";
    parameters[REQUEST_COMPLEX_BEHAVIOURS] = @"returnnulls";
    
    BOOL cacheValid = NO;
    DisplayPathCache *cache = [self cacheEntryWithParameters:parameters context:self.managedObjectContext];
    
    if(cache && [parameters[REQUEST_PAGE_KEY] integerValue] <= 1 && !parameters[REQUEST_NO_CACHE])
    {
        if(self.delegate)
            cacheValid = [self.delegate isCacheValid:cache newRequestParameters:parameters];
        else
            cacheValid = [cache.date compare:[NSDate dateWithTimeIntervalSinceNow:-self.defaultCacheTime]] != NSOrderedAscending;
        
        completion([cache objectID],nil,cacheValid);
    }
    
    if(!cacheValid)
    {
        OMLoadDataTask *loadDataTask = [[OMLoadDataTask alloc]initWithCommand:command
                                                                   parameters:parameters
                                                                loginRequired:isLoginRequired
                                                                   completion:completion];
        [self startLoadingDataWithTask:loadDataTask];
        return loadDataTask;
    }
    
    return nil;
}

- (void) startLoadingDataWithTask:(OMLoadDataTask*)loadDataTask
{
    KNetworkManager *localSessionManager = [[KNetworkManager alloc] initWithBaseURL:self.serviceURL auth:loadDataTask.loginRequired];
    [localSessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [localSessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    if (loadDataTask.parameters[REQUEST_NO_CACHE]) {
        [localSessionManager.session.configuration addCacheHeaders:loadDataTask.parameters[REQUEST_NO_CACHE]];
    }else{
        [localSessionManager.session.configuration removeCacheHeaders];
    }
    
#if DEBUG && VERBOSE
    NSString *logVar = [NSString stringWithFormat:@"\n\nDisplayAlias: %@\nlogged: %d\n\n", loadDataTask.parameters[KrakeParamsKey.displayAlias], loadDataTask.loginRequired];
    for (NSHTTPCookie *cookies in localSessionManager.session.configuration.HTTPCookieStorage.cookies)
    {
        logVar = [logVar stringByAppendingFormat: @"\n%@=%@; path=%@; domain=%@; Expires:%@;", cookies.name, cookies.value, cookies.path, cookies.domain, cookies.expiresDate.description];
    }
    for (NSString *key in localSessionManager.session.configuration.HTTPAdditionalHeaders.allKeys)
    {
        logVar = [logVar stringByAppendingFormat: @"\n%@:%@", key, localSessionManager.session.configuration.HTTPAdditionalHeaders[key]];
    }
    NSLog(@"%@", logVar);
#endif
    
    [loadDataTask setSessionTask:
     [localSessionManager GET:loadDataTask.command
                   parameters:loadDataTask.parameters
                     progress: nil
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          
                          [self importAndSaveInCoreData:responseObject parameters:loadDataTask.parameters loadDataTask:loadDataTask];
                      }
                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                          [loadDataTask loadingFailed:task withError:error];
                          NSLog(@"ERROR : %@ (%@)", error.localizedDescription, task.currentRequest.URL.description);
                          if (error.code != -999)
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  loadDataTask.completionBlock(nil,error,YES);
                              });
                          else
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  loadDataTask.completionBlock(nil,nil,YES);
                              });
                      }]];
}

- (void) importAndSaveInCoreData:(id)responseObject parameters:(NSDictionary*)parameters loadDataTask:(OMLoadDataTask*)loadDataTask
{
    NSMutableDictionary* mappedObjectInLastRequest = [[NSMutableDictionary alloc] init];
    
    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [importContext setParentContext: self.managedObjectContext];
    
    [importContext performBlock:^{
        
        id importedObject = [self importDataWithSource:responseObject
                                     destinationObject:nil
                                           baseKeyPath:nil
                                         importContext:importContext
                             mappedObjectInLastRequest:mappedObjectInLastRequest];
        
        if (importedObject != nil) {
            
            DisplayPathCache *cache = [self saveDataForParameters:parameters response:importedObject context:importContext];
            
            [loadDataTask loadingCompletedWithImportedCache:cache];
            
            NSError *error;
            @try{
                [importContext save:&error];
                
                [self.managedObjectContext performBlockAndWait:^{
                    [self.managedObjectContext save:nil];
                }];
            }
            @catch(NSException *exception){
                
            }
            
            if(cache != nil)
            {
                if(loadDataTask && !loadDataTask.isCancelled)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loadDataTask.completionBlock([cache objectID],nil,YES);
                    });
                }
            }else if(cache == nil && !loadDataTask.isCancelled){
                NSMutableArray *privacyObjects = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)importedObject count]];
                for (id elem in importedObject) {
                    [privacyObjects addObject:[elem objectID]];
                }
                OMPrivacyViewController *privacyVC = [OMPrivacyViewController generateViewControllerWithObjectID:privacyObjects];
                
                [[[KNetworkAccess sharedInstance] delegate] privacy:privacyVC];
            }
        }
        else{
            // Calling the completion block on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                loadDataTask.completionBlock(nil,[NSError errorWithDomain:KInfoPlist.appName code:0 userInfo:@{NSLocalizedDescriptionKey : [@"invalid_entry_point" localizedString]}],YES);
            });
        }
    }];
}

- (id)importDataWithSource:(NSDictionary*)sourceInfos destinationObject:(id)destination baseKeyPath:(NSString *)baseKeyPath importContext:(NSManagedObjectContext*)importContext mappedObjectInLastRequest:(NSMutableDictionary*)mappedObjectInLastRequest
{
    NSString *name = sourceInfos[RESPONSE_NAME_KEY];
    
    if([self.configurations.garbageParts containsObject:name] == NO)
    {
        NSString *value = sourceInfos[RESPONSE_VALUE_KEY];
        
        NSArray *model = sourceInfos[RESPONSE_MODEL_KEY];
        
        NSArray *lists = sourceInfos[RESPONSE_LIST_KEY];
        
        NSDictionary *usefullList = nil;
        
        for(NSDictionary* listElement in lists)
        {
            if(![listElement[RESPONSE_NAME_KEY] isEqualToString:WIDGET_LIST_TYPE])
            {
                usefullList = listElement;
                break;
            }
        }
        
        
        NSString *contentType = [self valueForKey:RESPONSE_CONTENT_TYPE_KEY inModel:model];
        if(contentType == nil)
        {
            contentType = [value convertedValue];
        }
        
        if([contentType isKindOfClass:[NSString class]])
            contentType = [contentType cleanedClassName];
        
        
        if(model && [model count] > 0)
        {
            if (!usefullList && ![contentType matchesAnyOfRegex:self.configurations.multipleValuesKeyRegex])
            {
                Class destinationClass = NSClassFromString(contentType);
                if(destinationClass)
                {
                    id newDestination;
                    
                    NSNumber *identifier = nil;
                    NSString *stringIdentifier = nil;
                    
                    NSString *mapKey = nil;
                    if([destinationClass isSubclassOfClass:[ManagedMappedContentItem class]])
                    {
                        identifier = [self valueForKey:@"Id" inModel:model];
                        stringIdentifier = [self valueForKey:@"Sid" inModel:model];
                        if (stringIdentifier.length)
                            mapKey = stringIdentifier;
                        else
                            mapKey = [NSString stringWithFormat:@"%@:%@",destinationClass,identifier];
                    }
                    
                    if(mapKey)
                        newDestination = mappedObjectInLastRequest[mapKey];
                    
                    if(!newDestination)
                    {
                        if([destinationClass isSubclassOfClass:[ManagedMappedContentItem class]])
                        {
                            NSFetchRequest *request =[[NSFetchRequest alloc] initWithEntityName:contentType];
                            [request setPredicate:[NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"stringIdentifier"]
                                                                                     rightExpression:[NSExpression expressionForConstantValue:mapKey]
                                                                                            modifier:0
                                                                                                type:NSEqualToPredicateOperatorType
                                                                                             options:0]];
                            
                            newDestination = [[importContext executeFetchRequest:request error:nil] firstObject];
                        }
                        else
                        {
                            NSString *mappedKey = [self keyPathWithName:name baseKey:baseKeyPath];
                            if([destination respondsToSelector:NSSelectorFromString(mappedKey)])
                                newDestination = [destination valueForKey:mappedKey];
                        }
                        
                        if(!newDestination)
                        {
                            NSEntityDescription *entity = _managedObjectModel.entitiesByName[contentType];

                            if (entity != nil) {
                                newDestination = [NSEntityDescription insertNewObjectForEntityForName:contentType inManagedObjectContext:importContext];
                                if([destinationClass isSubclassOfClass:[ManagedMappedContentItem class]]){
                                    [(ManagedMappedContentItem*)newDestination setStringIdentifier:mapKey];
                                }
                            }
                        }
                        
                        if(mapKey != nil && newDestination != nil)
                        {
                            mappedObjectInLastRequest[mapKey] = newDestination;
                        }
                    }

                    if (newDestination != nil) {
                    [self importAllModelDataWithModel:model destination:newDestination baseKeyPath:nil importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
                    
                    [self setValue:newDestination forName:name baseKey:baseKeyPath inObject:destination];
                    }
                    
                    return newDestination;
                }
                else
                {
                    NSString *newBaseKeyPath;
                    
                    if([value isEqual:CONTENT_TYPE_CONTENT_PART])
                        newBaseKeyPath = baseKeyPath;
                    else
                        newBaseKeyPath = [self keyPathWithName:name baseKey:baseKeyPath];
                    [self importAllModelDataWithModel:model destination:destination baseKeyPath:newBaseKeyPath importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
                }
            }
            else
            {
                if(!usefullList)
                    [self importAllSubItems:model destination:destination name:name keyPath:baseKeyPath importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
                else
                {
                    NSMutableArray * projectionList = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *subItem in [usefullList objectForKey:RESPONSE_MODEL_KEY])
                    {
                        id importedValue = [self importDataWithSource:subItem destinationObject:nil baseKeyPath:nil importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
                        if (importedValue != nil) {
                        [projectionList addObject:importedValue];
                        }
                    }
                    return projectionList;
                }
            }
            
        }
        else
        {
            if ([contentType isKindOfClass:[NSString class]] == NO || ![contentType matchesAnyOfRegex:self.configurations.multipleValuesKeyRegex])
                [self setValue:[value convertedValue] forName:name baseKey:baseKeyPath inObject:destination];
            else if([contentType matchesAnyOfRegex:self.configurations.multipleValuesKeyRegex])
            {
                NSString *methodName = [self keyPathWithName:name baseKey:baseKeyPath];
                
                if([destination respondsToSelector:NSSelectorFromString(methodName)])
                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    NSArray * oldObjects = [[destination valueForKey:methodName] copy];
                    if ([[destination valueForKey:methodName] isKindOfClass:[NSOrderedSet class]])
                        [destination setValue:[NSOrderedSet orderedSet] forKey:methodName];
                    
//                    [destination performSelector:NSSelectorFromString([NSString stringWithFormat:@"remove%@:",[methodName stringWithUpperCaseFirstLetter]]) withObject:[destination valueForKey:methodName]];
                    [self deleteOldNonIdentifiedObjects:oldObjects];
#pragma clang diagnostic pop
                }
            }
        }
    }
    return nil;
    
}

- (NSString*)keyPathWithName:(NSString*)name baseKey:(NSString*)baseKey
{
    NSString *mappedName;

    if (self.configurations.specialNamesMapping[name] != nil) {
        name = self.configurations.specialNamesMapping[name];
    }

    if([baseKey length])
    {
        mappedName = [baseKey stringByAppendingString:[name stringWithUpperCaseFirstLetter]];
    }
    else
    {
        mappedName = name;
    }
    
    return [mappedName stringWithLowerCaseFirstLetter];
}

- (void)importAllModelDataWithModel:(NSArray*)model destination:(id)newDestination baseKeyPath:(NSString*)keyPath importContext:(NSManagedObjectContext*)importContext mappedObjectInLastRequest:(NSMutableDictionary*)mappedObjectInLastRequest
{
    for (NSDictionary *modelInfo in model)
    {
        [self importDataWithSource:modelInfo destinationObject:newDestination baseKeyPath:keyPath importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
    }
}

- (void)deleteOldNonIdentifiedObjects:(NSArray*)oldObjects
{
    for (NSManagedObject *object in oldObjects) {
        [self deleteOldNonIdentifiedObject:object];
    }
}

- (void)deleteOldNonIdentifiedObject:(NSManagedObject*)object
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSString *sid = [object respondsToSelector:@selector(stringIdentifier)] ? [object valueForKey:@"stringIdentifier"] : nil;
    NSNumber *idN = [object respondsToSelector:@selector(identifier)] ? [object valueForKey:@"identifier"] : nil;
    
    if (sid == nil && [idN integerValue] == 0)
    {
        [[object managedObjectContext] deleteObject:object];
    }
#pragma clang diagnostic pop
}

- (void)importAllSubItems:(NSArray*)model destination:(id)destination name:(NSString*)name keyPath:(NSString*)keyPath importContext:(NSManagedObjectContext*)importContext mappedObjectInLastRequest:(NSMutableDictionary*)mappedObjectInLastRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSString *methodName = [self keyPathWithName:name baseKey:keyPath];
    if([destination respondsToSelector:NSSelectorFromString(methodName)])
    {
        
        NSArray * oldObjects = [[destination valueForKey:methodName] copy];
        if ([[destination valueForKey:methodName] isKindOfClass:[NSOrderedSet class]])
            [destination setValue:[NSOrderedSet orderedSet] forKey:methodName];
        
//        [destination performSelector:NSSelectorFromString([NSString stringWithFormat:@"remove%@:",[methodName stringWithUpperCaseFirstLetter]]) withObject:oldObjects];
        [self deleteOldNonIdentifiedObjects:oldObjects];
        
        NSString *addMethodName = [NSString stringWithFormat:@"add%@Object:",[methodName stringWithUpperCaseFirstLetter]];
        
        for (NSDictionary *subItem in model)
        {
            id importedValue = [self importDataWithSource:subItem destinationObject:nil baseKeyPath:nil importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
            if(importedValue != nil && ![[destination valueForKey:methodName] containsObject:importedValue])
            {
                NSRelationshipDescription *relationship = [[(NSManagedObject*)destination entity] propertiesByName][methodName];
                if([[relationship destinationEntity] isEqual:[(NSManagedObject*)importedValue entity]]){
                    
                    [destination performSelector:NSSelectorFromString(addMethodName) withObject:importedValue];
                    
                }
            }
        }
    }
    else
    {
        NSMutableSet *resetedLists = [NSMutableSet set];
        
        for (NSDictionary *subItem in model)
        {
            for (NSDictionary *subSubItem in [subItem objectForKey:RESPONSE_MODEL_KEY])
            {
                NSString *newName = [subSubItem objectForKey:RESPONSE_NAME_KEY];
                
                NSString *subMethodName = [self keyPathWithName:newName baseKey:methodName];
                
                if([destination respondsToSelector:NSSelectorFromString(subMethodName)])
                {
                    if(![resetedLists containsObject:subMethodName])
                    {
                        NSArray *oldObjects =[[destination valueForKey:subMethodName] copy];
                        if ([[destination valueForKey:subMethodName] isKindOfClass:[NSOrderedSet class]])
                            [destination setValue:[NSOrderedSet orderedSet] forKey:subMethodName];
//                        [destination performSelector:NSSelectorFromString([NSString stringWithFormat:@"remove%@:",[subMethodName stringWithUpperCaseFirstLetter]]) withObject:oldObjects];
                        [self deleteOldNonIdentifiedObjects:oldObjects];
                        [resetedLists addObject:subMethodName];
                    }
                    
                    id importedValue = [self importDataWithSource:subSubItem destinationObject:nil baseKeyPath:nil importContext:importContext mappedObjectInLastRequest:mappedObjectInLastRequest];
                    
                    if(importedValue != nil && ![[destination valueForKey:subMethodName] containsObject:importedValue])
                    {
                        NSRelationshipDescription *relationship = [[(NSManagedObject*)destination entity] propertiesByName][subMethodName];
                        if([[relationship destinationEntity] isEqual:[(NSManagedObject*)importedValue entity]]){
                            [destination performSelector:NSSelectorFromString( [NSString stringWithFormat:@"add%@Object:",[subMethodName stringWithUpperCaseFirstLetter]]) withObject:importedValue];
                            
                        }
                    }
                }
                
            }
        }
    }
#pragma clang diagnostic pop
}

- (id)valueForKey:(NSString *)key inModel:(NSArray*)model
{
    for (NSDictionary *modelInfo in model)
    {
        if([modelInfo[RESPONSE_NAME_KEY] isEqual:key])
        {
            return [modelInfo[RESPONSE_VALUE_KEY] convertedValue];
        }
    }
    return nil;
}

- (void)setValue:(id)value forName:(NSString*)name baseKey:(NSString*)baseKeyPath inObject:(id)object
{
    NSString *mappedClassKey = [self keyPathWithName:name baseKey:baseKeyPath];
    
    if([object respondsToSelector:NSSelectorFromString(mappedClassKey)])
    {
        id oldObject = [value isKindOfClass:[NSManagedObject class]] ? [object valueForKeyPath:mappedClassKey] : nil;
        
        
        
        @try {
            if (value){
                [object setValue:value forKeyPath:mappedClassKey];
            }else{
                [object setNilValueForKey:mappedClassKey];
            }
        }
        @catch (NSException *exception) {
            
        }
        
        if(oldObject != value && [oldObject isKindOfClass:[NSManagedObject class]])
        {
            [self deleteOldNonIdentifiedObject:(NSManagedObject*)oldObject];
        }
    }
}

- (DisplayPathCache*)cacheEntryWithParameters:(NSDictionary*)parameters context:(NSManagedObjectContext*)context
{
    NSString *displayAlias =parameters[KParametersKeys.displayAlias];
    if ([displayAlias length])
    {
        NSString *cacheName;
        
        if(self.delegate)
            cacheName = [self.delegate displayCacheNameWithDisplayAlias:displayAlias
                                                             parameters:parameters];
        else
            cacheName = displayAlias;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[DisplayPathCache class] description]];
        
        [request setPredicate:[NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"displayPath"]
                                                                 rightExpression:[NSExpression expressionForConstantValue:cacheName]
                                                                        modifier:0
                                                                            type:NSEqualToPredicateOperatorType
                                                                         options:NSCaseInsensitivePredicateOption]];
        
        return [[context executeFetchRequest:request error:nil] firstObject];
    }
    else
        return nil;
}

- (DisplayPathCache*)saveDataForParameters:(NSDictionary*)parameters response:(id)response context:(NSManagedObjectContext*)context
{
    if(parameters[REQUEST_SHOW_PRIVACY] || ![response isKindOfClass:[NSArray class]] || ![[(NSArray*)response firstObject] conformsToProtocol:@protocol(PolicyProtocol)])
    {
        DisplayPathCache *savedCache = [self cacheEntryWithParameters:parameters context:context];
        if(!savedCache)
        {
            savedCache = [NSEntityDescription insertNewObjectForEntityForName:[[DisplayPathCache class] description] inManagedObjectContext:context];
            savedCache.displayPath = [self.delegate displayCacheNameWithDisplayAlias:parameters[KParametersKeys.displayAlias]
                                                                          parameters:parameters];
        }
        savedCache.extrasParameters = parameters;
        
        savedCache.date = [NSDate date];
        
        if([parameters[REQUEST_PAGE_KEY] integerValue] <= 1)
        {
            [savedCache removeCacheItems:savedCache.cacheItems];
        }
        
        if([response isKindOfClass:[NSArray class]])
        {
            for (ManagedMappedContentItem *object in response)
            {
                [savedCache addCacheItemsObject:object];
            }
        }
        else
        {
            [savedCache addCacheItemsObject:response];
        }
        
        return savedCache;
    }
    return nil;
}

- (DisplayPathCache* __nonnull) displayPathCacheFromObjectID:(NSManagedObjectID* __nonnull)objectID
{
    return (DisplayPathCache*)[self.managedObjectContext objectWithID:objectID];
}

@end
