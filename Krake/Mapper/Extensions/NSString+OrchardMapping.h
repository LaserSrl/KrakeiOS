//
//  NSString+OrchardMapping.h
//  OrchardGen
//
//  Created by joel on 23/06/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OrchardMapping)

- (NSString*)stringWithLowerCaseFirstLetter;

- (NSString*)stringWithUpperCaseFirstLetter;


- (BOOL)matchesAnyOfRegex:(NSArray*)expressions;

- (NSString*)cleanedClassName;

- (BOOL)beginWithLowerCaseLetter;

- (NSString*)localizedString;

@end

@interface NSObject (OrchardCovert)

- (id)convertedValue;
@end
