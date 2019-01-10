//
//  NSMutableDictionary+OGLParameters.h
//  OrchardGen
//
//  Created by joel on 29/01/15.
//  Copyright (c) 2015 Laser. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface NSMutableDictionary (OGLParameters)


+ (NSMutableDictionary<NSString*,id> *__nonnull )requestExtrasToLoadCategorySubTerms DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize fieldsFilter:(NSString* __nullable)fieldsFilter DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasWithLocation:(CLLocation* __nonnull)location radius:(NSUInteger)radiusInChilometers DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasWithLocation:(CLLocation* __nonnull)location
                                   radius:(NSUInteger)radiusInChilometers
                                     page:(NSUInteger)page
                                 pageSize:(NSUInteger)pageSize
                                    fieldsFilter:(NSString* __nullable)fieldsFilter DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasShowPrivacy DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasNoCache DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

+ (NSMutableDictionary<NSString*,id> * __nonnull)requestExtrasWithDeepLevel:(NSUInteger)deepLevel DEPRECATED_MSG_ATTRIBUTE("Use KRequestParameters");

@end
