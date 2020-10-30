//
//  OGLConfigurations.m
//  OrchardGen
//
//  Created by joel on 25/06/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

#import "OGLConfigurations.h"
#import "OGLCoreDataMapper.h"
#import <Krake/Krake-Swift.h>

NSString *const USER_INFO_DISPLAY_ALIAS = @"user+info";

//INPUT
NSString *const REQUEST_DISPLAY_PATH_KEY = @"displayAlias";
NSString *const REQUEST_LANGUAGE_KEY = @"lang";
NSString *const REQUEST_PAGE_KEY = @"page";
NSString *const REQUEST_PAGE_SIZE_KEY = @"pageSize";
NSString *const REQUEST_ITEMS_FIELDS_FILTER = @"mfilter";
NSString *const REQUEST_RESULT_TARGET = @"resultTarget";
NSString *const REQUEST_SHOW_PRIVACY = @"showPrivacy";
NSString *const REQUEST_REAL_FORMAT = @"realformat";
NSString *const REQUEST_COMPLEX_BEHAVIOURS = @"complexbehaviour";
NSString *const REQUEST_NO_CACHE = @"no-cache";
NSString *const REQUEST_DEEP_LEVEL = @"deepLevel";
NSString *const REQUEST_DATE_START = @"dataInizio";
NSString *const REQUEST_DATE_END = @"dataFine";
NSString *const REQUEST_TERMS = @"TermIds";
NSString *const REQUEST_AROUND_ME_LATITUDE = @"lat";
NSString *const REQUEST_AROUND_ME_LONGITUDE = @"lng";
NSString *const REQUEST_AROUND_ME_RADIUS = @"dist";

//OUTPUT
NSString *const RESPONSE_NAME_KEY = @"n";
NSString *const RESPONSE_VALUE_KEY = @"v";
NSString *const RESPONSE_MODEL_KEY = @"m";
NSString *const RESPONSE_LIST_KEY = @"l";
NSString *const RESPONSE_CONTENT_TYPE_KEY = @"ContentType";

//Output_values
NSString *const CONTENT_TYPE_PROJECTION_PAGE = @"ProjectionPage";
NSString *const CONTENT_TYPE_CONTENT_PART = @"ContentPart";
NSString *const WIDGET_LIST_TYPE = @"WidgetList";


@implementation OGLConfigurations

- (instancetype)init
{
    return [self initWithFileAtURL:[[NSBundle mainBundle] URLForResource:@"OGLMapperConfiguration" withExtension:@"plist"]];
}

- (instancetype)initWithFileAtURL:(NSURL *)url
{
    self = [super init];
    NSDictionary *configurations = [NSDictionary dictionaryWithContentsOfURL:url];
    
    if (self) {
        
#if __MAC_OS_X_VERSION_MAX_ALLOWED
        NSString *lang = @"it-IT";
#else
        NSString *lang = Core.language;
#endif
        
        _language = lang;
        _garbageParts = configurations[@"GarbageParts"];
        _specialNamesMapping = configurations[@"SpecialNamesMapping"];
        
        NSMutableArray *regexes = [NSMutableArray array];
        
        
        for (NSString *expression in configurations[@"MultipleValuesKeyRegex"])
        {
            [regexes addObject:[[NSRegularExpression alloc] initWithPattern:expression
                                                                    options:NSRegularExpressionCaseInsensitive
                                                                      error:nil]];
        }
        
        _multipleValuesKeyRegex = [NSArray arrayWithArray:regexes];
#if __MAC_OS_X_VERSION_MAX_ALLOWED
        NSString * webServices = @"Laser.Orchard.WebServices/";
#else
        NSString * webServices = [KAPIConstants.wsBasePath stringByAppendingString:@"/"];
#endif
        _commandGetByAlias = [webServices stringByAppendingString:configurations[@"GetByAlias"]];
        
    }
    return self;
}

@end
