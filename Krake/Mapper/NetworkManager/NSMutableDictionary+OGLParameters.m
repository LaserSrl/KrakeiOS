//
//  NSMutableDictionary+OGLParameters.m
//  OrchardGen
//
//  Created by joel on 29/01/15.
//  Copyright (c) 2015 Laser. All rights reserved.
//
#import "OGLConstants.h"
#import "NSMutableDictionary+OGLParameters.h"

@implementation NSMutableDictionary (OGLParameters)

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasToLoadCategorySubTerms
{
    return [@{REQUEST_RESULT_TARGET: @"SubTerms"}mutableCopy];
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize
{
    return [NSMutableDictionary requestExtrasWithPage:page pageSize:pageSize fieldsFilter:nil];
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasWithPage:(NSUInteger)page pageSize:(NSUInteger)pageSize fieldsFilter:(NSString*)fieldsFilter
{
    NSMutableDictionary *dictionary = [@{REQUEST_PAGE_KEY:@(page),REQUEST_PAGE_SIZE_KEY:@(pageSize)} mutableCopy];
    
    if([fieldsFilter length])
        dictionary[REQUEST_ITEMS_FIELDS_FILTER] = fieldsFilter;
    
    return dictionary;
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasWithLocation:(CLLocation*)location
                                   radius:(NSUInteger)radiusInChilometers
                                     page:(NSUInteger)page
                                 pageSize:(NSUInteger)pageSize
                             fieldsFilter:(NSString*)fieldsFilter
{
    NSMutableDictionary *dictionary = [@{REQUEST_PAGE_KEY:@(page),REQUEST_PAGE_SIZE_KEY:@(pageSize)} mutableCopy];
    
    if([fieldsFilter length])
        dictionary[REQUEST_ITEMS_FIELDS_FILTER] = fieldsFilter;
    
    dictionary[REQUEST_AROUND_ME_LATITUDE] = @(location.coordinate.latitude);
    
    dictionary[REQUEST_AROUND_ME_LONGITUDE] = @(location.coordinate.longitude);
    
    dictionary[REQUEST_AROUND_ME_RADIUS] = @(radiusInChilometers);
    
    return dictionary;
    
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasWithLocation:(CLLocation*)location radius:(NSUInteger)radiusInChilometers
{
    return [NSMutableDictionary requestExtrasWithLocation:location
                                                   radius:radiusInChilometers
                                                     page:1
                                                 pageSize:9999
            fieldsFilter:nil];
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasShowPrivacy
{
    return [@{REQUEST_SHOW_PRIVACY:@(YES)} mutableCopy];
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasNoCache
{
    return [@{REQUEST_NO_CACHE : [NSString stringWithFormat:@"%.f",[NSDate timeIntervalSinceReferenceDate]]} mutableCopy];
}

+ (NSMutableDictionary<NSString*,id> *__nonnull)requestExtrasWithDeepLevel:(NSUInteger)deepLevel
{
    return [@{REQUEST_DEEP_LEVEL:@(deepLevel)} mutableCopy];
}

@end
