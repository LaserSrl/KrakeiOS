//
//  OMPrivacyManager.h
//  OrchardGen
//
//  Created by Patrick on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OMPrivacyViewController : UIViewController

+(OMPrivacyViewController*)generateViewControllerWithObjectID:(id)importedObject;

-(void)checkStatus;

@end
