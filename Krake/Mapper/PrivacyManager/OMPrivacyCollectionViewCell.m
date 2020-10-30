//
//  OMPrivacyCollectionViewCell.m
//  OrchardGen
//
//  Created by Patrick on 08/04/15.
//  Copyright (c) 2015 Dream Team. All rights reserved.
//

#import "OMPrivacyCollectionViewCell.h"
#import "NSString+OrchardMapping.h"
#import "OGLCoreDataMapper.h"
#import <Krake/Krake-Swift.h>

@implementation OMPrivacyCollectionViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    WKWebView *privacyBody = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration default]];
    self.privacyBody = privacyBody;
    privacyBody.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addSubview:privacyBody];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[privacyBody]-(8)-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:@{@"privacyBody": privacyBody}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[privacyBody]-(8)-[label]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:@{@"privacyBody": privacyBody, @"label" : self.labelSwitch}]];
    privacyBody.scrollView.bounces = NO;
    
}

-(IBAction)changeStatus:(id)sender{
    
    [self.response setValue:[NSNumber numberWithBool:self.switcher.on] forKey:[self.elem.identifier stringValue]];
    
    [self.parent checkStatus];
}

-(void)setResponse:(NSMutableDictionary *)response{
    _response = response;
    if (![self.response valueForKey:[self.elem.identifier stringValue]]) {
        [self.response setValue:@(0) forKey:[self.elem.identifier stringValue]];
        
    }
    [self.switcher setOn:[[self.response valueForKey:[self.elem.identifier stringValue]] boolValue]];
}

-(void)setElem:(id<PolicyProtocol>)elem{
    _elem = elem;
    NSString *familyName = [[UIFont systemFontOfSize:12.0] familyName];
    NSString *stringHtml = [NSString stringWithFormat:@"<center><h2>%@</h2></center><p style='text-align:justify;'>%@</p>", elem.titlePartTitle, elem.bodyPartText ];
    stringHtml = [NSString stringWithFormat:@"<div style='text-align:justify;font-family:\"%@\";'>%@</div>", familyName , stringHtml];
    [self.privacyBody loadHTMLString:stringHtml baseURL:nil];
    
    [self.switcher setOn:false];
    [[KTheme currentObjc] applyThemeToSwitch:self.switcher style:SwitchStylePolicy];
    NSMutableString *stringPrivacy = [[NSMutableString alloc] init];
    
    if ([elem.policyTextInfoPartPolicyType caseInsensitiveCompare:@"policy"] == NSOrderedSame){
        [stringPrivacy appendString:Policies.acceptTerm];
    }else if ([elem.policyTextInfoPartPolicyType caseInsensitiveCompare:@"regulation"] == NSOrderedSame){
        [stringPrivacy appendString:Policies.confirmRead];
    }
    
    if (elem.policyTextInfoPartUserHaveToAccept.integerValue == 1)
        [stringPrivacy appendString: Policies.required];
    
    
    
    self.labelSwitch.text = stringPrivacy;
    self.labelSwitch.adjustsFontSizeToFitWidth = true;
    self.labelSwitch.minimumScaleFactor = 0.1;
}

@end
