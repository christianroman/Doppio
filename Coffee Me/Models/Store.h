//
//  Store.h
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Mantle/Mantle.h>

@class Address;
@class Coordinates;

@interface Store : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong, readwrite) NSNumber *distance;
@property (nonatomic, copy, readonly) NSNumber *ID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *brandName;
@property (nonatomic, strong, readonly) Address *adress;
@property (nonatomic, strong, readonly) Coordinates *coordinates;
@property (nonatomic, copy, readonly) NSDate *regularHours;
@property (nonatomic, copy, readonly) NSDate *extendedHours;
@property (nonatomic, copy, readonly) NSDate *today;

@end
