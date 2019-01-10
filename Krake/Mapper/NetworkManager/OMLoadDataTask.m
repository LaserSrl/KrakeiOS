//
//  OMLoadDataTask.m
//  OrchardGen
//
//  Created by joel on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import "OMLoadDataTask.h"
#import <Krake/Krake-Swift.h>
#import "OGLCoreDataMapper.h"
#import "NSString+OrchardMapping.h"
#import "OGLCoreDataMapper_OMPrivateMethods.h"

@interface OMLoadDataTask ()
{
    OMLoadDataTask *selfRetain;
    BOOL observingPrivacy;
}

@property (nonatomic, strong) NSURLSessionDataTask *urlSessionTask;

@end

@implementation OMLoadDataTask

- (instancetype)initWithCommand:(NSString *)command parameters:(NSDictionary *)parameters loginRequired:(BOOL)loginRequired completion:(OMMapperCompletionBlock)completionBlock
{
    self = [super init];
    if (self) {
        selfRetain = self;
        _parameters = parameters;
        _loginRequired = loginRequired;
        _command = command;
        _completionBlock = completionBlock;
    }
    return self;
}

- (void)setSessionTask:(NSURLSessionDataTask *)sessionTask
{
    _urlSessionTask = sessionTask;
}

- (void)cancel
{
    [self.urlSessionTask cancel];
    _cancel = YES;
    // [self closeAndClean];
}


- (void)loadingFailed:(NSURLSessionDataTask*)task withError:(NSError*)error
{
    [self closeAndClean];
}

-(void)loadingCompletedWithImportedCache:(DisplayPathCache *)cache
{
    if(!cache ){
        if(!observingPrivacy){
            observingPrivacy = YES;
            [[KNetworkAccess sharedInstance] addObserver:self forKeyPath:@"privacyStatus" options:NSKeyValueObservingOptionNew context:nil];
        }
    }else{
        [self closeAndClean];
    }
}

- (void)closeAndClean
{
    selfRetain = nil;
    
    if(observingPrivacy)
    {
        [[KNetworkAccess sharedInstance] removeObserver:self forKeyPath:@"privacyStatus"];
    }
}

- (void)dealloc
{
    //    NSLog(@"I'm dying...");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == [KNetworkAccess sharedInstance] && [keyPath isEqualToString:@"privacyStatus"] && change != nil)
    {
        OMPrivacyStatus status = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        
        if(status == OMPrivacyStatusAccepted)
        {
            observingPrivacy = NO;
            
            [[KNetworkAccess sharedInstance] removeObserver:self forKeyPath:@"privacyStatus"];
            
            [self restartDataLoading];
        }else if(status == OMPrivacyStatusNotAccepted)
        {
            observingPrivacy = NO;
            
            [[KNetworkAccess sharedInstance] removeObserver:self forKeyPath:@"privacyStatus"];
            self.completionBlock(nil, [[NSError alloc] initWithDomain:@"Privacy" code:OMPrivacyClose_Error_Code userInfo:@{NSLocalizedDescriptionKey: [@"undo_privacy" localizedString]}], YES);
        }
    }
}

- (void)restartDataLoading
{
    [[OGLCoreDataMapper sharedInstance] startLoadingDataWithTask:self];
}

@end
