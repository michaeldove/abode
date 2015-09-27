//
//  IrrigationClient.m
//  Abode
//
//  Created by Michael Dove on 28/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import "IrrigationClient.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Mantle/Mantle.h>

#import "Zone.h"

@interface IrrigationClient ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation IrrigationClient

- (instancetype)initWithHostName:(NSString *)hostName {
    if (self = [super init]) {
        NSString *url = [NSString stringWithFormat:@"http://%@/", hostName];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (RACSignal *)fetchZonesSignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self.sessionManager GET:@"zones" parameters:nil success:^(NSURLSessionDataTask *task, NSArray *response) {
            NSError *error = nil;
            NSArray *zones = [MTLJSONAdapter modelsOfClass:Zone.class fromJSONArray:response error:&error];
            if (error) {
                [subscriber sendError:error];
            }
            else {
                [subscriber sendNext:zones];
                [subscriber sendCompleted];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)setZoneId:(NSNumber *)zoneId signalWithOn:(BOOL)on
{
    NSDictionary *payload = @{@"on" : on ? @1 : @0};
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *relativePath = [NSString stringWithFormat:@"zones/%@", zoneId];
        NSURLSessionDataTask *task =  [self.sessionManager PUT:relativePath parameters:payload success:^(NSURLSessionDataTask *task, NSArray *response) {
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

@end
