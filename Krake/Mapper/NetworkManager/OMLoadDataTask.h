//
//  OMLoadDataTask.h
//  OrchardGen
//
//  Created by joel on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGLCoreDataMapper.h"

@interface OMLoadDataTask : NSObject

typedef NS_ENUM(NSUInteger, OMLoadResultType)
{
    OMLoadResultTypeSuccess,
    OMLoadResultTypePrivacy
};

@property (nonatomic, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) NSString *command;
@property (nonatomic, readonly) BOOL loginRequired;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancel;
@property (nonatomic, readonly) OMMapperCompletionBlock completionBlock;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCommand:(NSString*)command parameters:(NSDictionary *)parameters loginRequired:(BOOL)loginRequired completion:(OMMapperCompletionBlock)completionBlock;

- (void)setSessionTask:(NSURLSessionDataTask*)sessionTask;

- (void)cancel;

- (void)loadingFailed:(NSURLSessionDataTask*)task withError:(NSError*)error;

- (void)loadingCompletedWithImportedCache:(DisplayPathCache* )cache;

@end
