//
//  NSObject+Reachability_Reactive.h
//  Abode
//
//  Created by Michael Dove on 2/04/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Reachability/Reachability.h>

@interface Reachability (Reachability_Reactive)

+ (RACSignal *) rac_signalForHost:(NSString *)host;

@end
