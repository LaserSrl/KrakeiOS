//
//  OGLCoreDataMapper.h
//  OrchardGen
//
//  Created by joel on 21/10/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

@import Foundation;
@import CoreData;

@protocol KMCacheManagerDelegate;
@class OGLConfigurations;
@class OMLoadDataTask;
@class DisplayPathCache;

extern NSUInteger const OMPrivacyClose_Error_Code;

typedef void(^OMMapperCompletionBlock)( NSManagedObjectID* __nullable parsedObject, NSError* __nullable error, BOOL completed);

@interface OGLCoreDataMapper : NSObject

@property (nonatomic, weak) id<KMCacheManagerDelegate> __nullable delegate;
@property (nonatomic,readonly) NSURL*  __nonnull serviceURL;
@property (nonatomic, readonly) OGLConfigurations* __nonnull configurations;
@property (nonatomic, readonly) NSManagedObjectContext*  __nonnull managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel*  __nonnull managedObjectModel;

@property (nonatomic, readonly) NSTimeInterval defaultCacheTime;


+(OGLCoreDataMapper* __nonnull)sharedInstance;
+(void)setSharedInstance:(OGLCoreDataMapper* __nonnull)OGLCoreDataMapper;

-(instancetype __nonnull)init UNAVAILABLE_ATTRIBUTE;

/**
 *  Iniliazza un mapper, con configirazioni di default
 *
 *  @param context di base dell'app
 *
 *  @return mapper
 */
- (instancetype __nonnull)initWithManagedObjectContext:(NSManagedObjectContext* __nonnull)context model:(NSManagedObjectModel* __nonnull) model;

/**
 *  Iniliazza un mapper, con configirazioni di default
 *
 *  @param serviceURL URL di base del WS
 *
 *  @return mapper
 */
- (instancetype __nonnull)initWithServiceURL:(NSURL* __nonnull)serviceURL managedObjectContext:(NSManagedObjectContext* __nonnull)context model:(NSManagedObjectModel* __nonnull) model;

/**
 *  Iniliazza un mapper, specificando le configurazioni
 *
 *  @param serviceURL     url di base del WS
 *  @param configurations configurazioni del WS
 *
 *  @return mapper configurato
 */
- (instancetype __nonnull)initWithServiceURL:(NSURL * __nonnull)serviceURL managedObjectContext:(NSManagedObjectContext* __nonnull)context model:(NSManagedObjectModel* __nonnull) model configurations:(OGLConfigurations* __nullable)configurations;

/**
 *   Metodo per dati dal server tramite display path specificando parametri aggiuntivi
 *
 *  @param displayAlias       autoroutePartDisplayPath
 *  @param extrasParameters parametri aggiuntivi per il caricamento dei dati. Nella category NSDictionary(OGLParameters) sono presenti i metodi per creare i parametri comuni
 *  @param completion       blocco da invocare alla fine del caricamento.
 */
- (OMLoadDataTask* __nonnull) loadDataWithDisplayAlias:(NSString* __nonnull)displayAlias extras:(NSDictionary* __nullable)extrasParameters completionBlock:(OMMapperCompletionBlock __nonnull)completion;
/**
 *  Metodo per dati dal server tramite display path specificando parametri aggiuntivi
 *
 *  @param displayAlias     autoroutePartDisplayPath
 *  @param extrasParameters parametri aggiuntivi per il caricamento dei dati. Nella category NSDictionary(OGLParameters) sono presenti i metodi per creare i parametri comuni
 *  @param isLoginRequired  indicazione se il caricamento richiede la login
 *  @param completion       blocco da invocare alla fine del caricamento.
 *
 *  @return task to cancel data loading
 */
- (OMLoadDataTask* __nonnull) loadDataWithDisplayAlias:(NSString* __nonnull)displayAlias extras:(NSDictionary* __nullable)extrasParameters loginRequired:(BOOL)isLoginRequired completionBlock:(OMMapperCompletionBlock __nonnull)completion;


- (OMLoadDataTask* __nonnull) loadDataWithController:(NSString* __nonnull)controller extras:(NSDictionary* __nullable)extrasParameters loginRequired:(BOOL)isLoginRequired completionBlock:(OMMapperCompletionBlock __nonnull)completion;

- (DisplayPathCache* __nullable)cacheEntryWithParameters:(NSDictionary* __nonnull)parameters context:(NSManagedObjectContext* __nonnull)context;

- (DisplayPathCache* __nonnull) displayPathCacheFromObjectID:(NSManagedObjectID* __nonnull)objectID;

- (void) importAndSaveInCoreData:(id _Nonnull)responseObject parameters:(NSDictionary* __nullable)parameters loadDataTask:(OMLoadDataTask* __nullable)loadDataTask;

@end
