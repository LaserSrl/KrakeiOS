//
//  LBClock.h
//  GameQuiz
//
//  Created by Patrick on 16/06/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

@import Foundation;

@interface LBClock : NSObject
+ (instancetype)sharedClock;
// since device boot or something. Monotonically increasing, unaffected by date and time settings
- (NSTimeInterval)absoluteTime;

- (NSTimeInterval)machAbsoluteToTimeInterval:(uint64_t)machAbsolute;
@end