//
//  OGLConfigurations.h
//  OrchardGen
//
//  Created by joel on 25/06/14.
//  Copyright (c) 2014 Laser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGLConfigurations : NSObject

/**
 *  The server command to get JSON data.
 *  Default: Json/GetByAlias
 */
@property (nonatomic, strong) NSString *commandGetByAlias;

@property (nonatomic, strong) NSArray *garbageParts;
@property (nonatomic,strong) NSDictionary *specialNamesMapping;
@property (nonatomic,strong) NSArray *multipleValuesKeyRegex;

/**
 *  Language per la chiamata al WS.
 *  Default: identifier della locale corrente
 */
@property (nonatomic, strong) NSString *language;

/**
 *  Configurazione di default. Caricate dal file OGLMapper nel main bundle
 *
 *  @return <#return value description#>
 */
- (id)init;

- (id)initWithFileAtURL:(NSURL*)url;

@end
