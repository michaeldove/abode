//
//  AbodeCoordinator.m
//  Abode
//
//  Created by Michael Dove on 30/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import "AbodeCoordinator.h"
#import "NSNetService+ReactiveNetService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Reachability/Reachability.h>
#import "Reachability+Reachability_Reactive.h"

#import <arpa/inet.h>


@interface AbodeCoordinator ()

@property (nonatomic, strong) RACSignal *resolvedSignal;

@end

@implementation AbodeCoordinator

+ (RACSignal *)rac_nodeAddresses {
    RACSignal *serviceAddressSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSignal *resolvedSignal = [NSNetService rac_resolvedServicesOfType:@"_abode._tcp." inDomain:@"local"];
        [resolvedSignal subscribeNext:^(id x) {
            RACSequence *services = x;
            [[services take:1].signal subscribeNext:^(id serviceObj) {
                NSNetService *service = serviceObj;
                RACSignal *reachableSignal = [self reachable:service.hostName];
                [reachableSignal subscribeNext:^(id x) {
                    NSLog(@"Reachable: %@", x);
                    NSString *relativeHostName = [service.hostName substringToIndex:service.hostName.length - 1];
                    NSString *serviceAddress = [NSString stringWithFormat:@"%@:%ld", relativeHostName, service.port];
                    [subscriber sendNext:serviceAddress];
                }];
            }];
        }];
        return [RACDisposable disposableWithBlock:^{

        }];
    }];
    return serviceAddressSignal;
}

+ (RACSignal *)reachable:(NSString *)host {
    return [Reachability rac_signalForHost:host];
}

@end
