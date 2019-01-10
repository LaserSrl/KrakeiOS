//
//  OMSystemInfo.m
//  OrchardGen
//
//  Created by joel on 05/02/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

#import "OMSystemInfo.h"
#include <sys/utsname.h>

@interface OMSystemInfo ()
{
    struct utsname systemInfo;
}
@end

@implementation OMSystemInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        uname(&systemInfo);
        
    }
    return self;
}

- (NSString *)machine
{
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
@end
