//
//  OGLConstants.h
//  OrchardGen
//
//  Created by joel on 25/06/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

#ifndef OrchardGen_OGLConstants_h

#import <Foundation/Foundation.h>

extern NSString *const USER_INFO_DISPLAY_ALIAS ;

//INPUT
extern NSString *const REQUEST_DISPLAY_PATH_KEY ;
extern NSString *const REQUEST_LANGUAGE_KEY ;
extern NSString *const REQUEST_PAGE_KEY;
extern NSString *const REQUEST_PAGE_SIZE_KEY;
extern NSString *const REQUEST_ITEMS_FIELDS_FILTER;
extern NSString *const REQUEST_RESULT_TARGET;
extern NSString *const REQUEST_SHOW_PRIVACY;
extern NSString *const REQUEST_REAL_FORMAT;
extern NSString *const REQUEST_COMPLEX_BEHAVIOURS;
extern NSString *const REQUEST_NO_CACHE;
extern NSString *const REQUEST_DEEP_LEVEL;
extern NSString *const REQUEST_DATE_START;
extern NSString *const REQUEST_DATE_END;
extern NSString *const REQUEST_TERMS;

extern NSString *const REQUEST_AROUND_ME_LATITUDE;
extern NSString *const REQUEST_AROUND_ME_LONGITUDE;
/**
 *  Il raggio deve essere indicato in chilometri
 */
extern NSString *const REQUEST_AROUND_ME_RADIUS;

//OUTPUT
extern NSString * const RESPONSE_NAME_KEY ;
extern NSString *const RESPONSE_VALUE_KEY ;
extern NSString *const RESPONSE_MODEL_KEY;
extern NSString *const RESPONSE_LIST_KEY ;
extern NSString *const RESPONSE_CONTENT_TYPE_KEY;

//Output_values
extern NSString *const CONTENT_TYPE_PROJECTION_PAGE;
extern NSString *const CONTENT_TYPE_CONTENT_PART;
extern NSString *const WIDGET_LIST_TYPE;

#endif
