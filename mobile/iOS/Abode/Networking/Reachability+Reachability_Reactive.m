//
//  NSObject+Reachability_Reactive.m
//  Abode
//
//  Created by Michael Dove on 2/04/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import "Reachability+Reachability_Reactive.h"
#import <Reachability/Reachability.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import <arpa/inet.h>

@implementation Reachability (Reachability_Reactive)

+ (RACSignal *) rac_signalForHost:(NSString *)host {
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        Reachability *reach = [Reachability reachabilityWithHostName:host];
        reach.reachableBlock = ^(Reachability *reach) {
            [subscriber sendNext:reach];
        };
        reach.unreachableBlock = ^(Reachability *reach) {
            [subscriber sendNext:reach];
        };
        [reach startNotifier];
        
        return [RACDisposable disposableWithBlock:^{
            [reach stopNotifier];
        }];
    }];
    return signal;
}

@end

