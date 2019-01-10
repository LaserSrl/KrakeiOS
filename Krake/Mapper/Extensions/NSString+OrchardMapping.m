//
//  NSString+OrchardMapping.m
//  OrchardGen
//
//  Created by joel on 23/06/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

#import "OGLConfigurations.h"
#import "NSString+OrchardMapping.h"

static NSNumberFormatter *f;

@implementation NSString (OrchardMapping)

- (BOOL)beginWithLowerCaseLetter
{
    NSString *firstLetter = [self substringToIndex:1];
    return [firstLetter isEqualToString:[firstLetter lowercaseString]];
}

- (NSString*)stringWithLowerCaseFirstLetter
{
    if([self length])
    {
        NSString *firstLetter = [self substringToIndex:1];
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[firstLetter lowercaseString]];
    }
    return self;
}

- (NSString*)stringWithUpperCaseFirstLetter
{
    if([self length])
    {
        NSString *firstLetter = [self substringToIndex:1];
        return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[firstLetter uppercaseString]];
    }
    return self;
}

- (NSNumber*) parsedNumber
{
    if(f == nil)
    {
        f = [[NSNumberFormatter alloc] init];
        [f setLocale: [NSLocale localeWithLocaleIdentifier:@"en-US"]];
        
        [f setAllowsFloats:YES];
    }
    return [f numberFromString:self];
}


- (BOOL)containsDateValue
{
    return [self beginAndEndWithCharacter:'#'];
}

- (BOOL)beginAndEndWithCharacter:(unichar)character
{
    if(self.length > 2)
    {
        return [self characterAtIndex:0] == character && [self characterAtIndex:self.length-1] == character;
    }
    return NO;
}

- (NSDate*)parsedDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'#'MM/dd/yyyy HH:mm:ss'#'"];
    
    return [formatter dateFromString:self];
}

- (BOOL)matchesAnyOfRegex:(NSArray*)expressions
{
    for ( NSRegularExpression *regex   in expressions)
    {
        if([[regex matchesInString:self options:0 range:NSMakeRange(0, [self length])] count])
            return YES;
    }
    return NO;
}

- (NSString *)cleanedClassName
{
    NSString *name = [self stringWithUpperCaseFirstLetter];
    NSRange range = [name rangeOfString:@"-"];
    
    if(range.location != NSNotFound)
    {
        return [name substringToIndex:range.location];
    }
    
    return name;
}

-(NSString *)localizedString{
    NSBundle *bundle = [NSBundle bundleForClass:[OGLConfigurations class]];
    return [bundle localizedStringForKey:self value:nil table:@"OCLocalizable"];
}

@end

@implementation NSObject (OrchardCovert)

- (id)convertedValue
{
    if ([self isKindOfClass:[NSString class]])
    {
        NSString *selfString = (NSString*)self;
        
        if([selfString containsDateValue])
        {
            return [selfString parsedDate];
        }
        
        return selfString;
        
    }
    else if(self == [NSNull null])
        return nil;
    else
        return self;
}



@end
