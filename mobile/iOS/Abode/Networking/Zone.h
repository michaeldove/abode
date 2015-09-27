//
//  Zone.h
//  Abode
//
//  Created by Michael Dove on 28/03/2015.
//  Copyright (c) 2015 Michael Dove. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Zone : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *shortDescription;
@property (nonatomic, readonly) BOOL on;
@property (nonatomic, copy, readonly) NSNumber *zoneId;

@end
