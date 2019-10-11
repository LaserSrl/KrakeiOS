//
//  OGLCoreDataMapper_OMPrivateMethods.h
//  OrchardGen
//
//  Created by joel on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import "OGLCoreDataMapper.h"

@interface OGLCoreDataMapper ()
- (void) importAndSaveInCoreData:(id)responseObject parameters:(NSDictionary*)parameters loadDataTask:(OMLoadDataTask*)loadDataTask;
@end
