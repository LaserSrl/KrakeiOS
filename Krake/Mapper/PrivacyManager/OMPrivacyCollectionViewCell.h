//
//  OMPrivacyCollectionViewCell.h
//  OrchardGen
//
//  Created by Patrick on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;
@protocol PolicyProtocol;
#import "OMPrivacyViewController.h"

@interface OMPrivacyCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet WKWebView *privacyBody;


@property (strong, nonatomic) id<PolicyProtocol> elem;
@property (strong, nonatomic) OMPrivacyViewController *parent;
@property (strong, nonatomic) NSMutableDictionary *response;

@end
