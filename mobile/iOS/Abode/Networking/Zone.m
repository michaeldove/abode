//
//  Zone.m
//  Abode
//
//  Created by Michael Dove on 28/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import "Zone.h"

@implementation Zone


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"zoneId": @"id",
             @"on": @"on",
             @"shortDescription": @"description",
             };
}

@end
