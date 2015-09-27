//
//  AbodeCoordinator.h
//  Abode
//
//  Created by Michael Dove on 30/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface AbodeCoordinator : NSObject

+ (RACSignal *)rac_nodeAddresses;

@end
