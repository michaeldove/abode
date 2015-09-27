//
//  IrrigationClient.h
//  Abode
//
//  Created by Michael Dove on 28/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface IrrigationClient : NSObject

- (instancetype)initWithHostName:(NSString *)hostName;
- (RACSignal *)fetchZonesSignal;
- (RACSignal *)setZoneId:(NSNumber *)zoneId signalWithOn:(BOOL)on;

@end
