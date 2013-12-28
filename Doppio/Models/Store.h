//
//  Store.h
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Store : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *address1;
@property (nonatomic, copy, readonly) NSString *address2;
@property (nonatomic, copy, readonly) NSString *features;
@property (nonatomic, copy, readonly) NSNumber *ID;
@property (nonatomic, copy, readonly) NSNumber *lat;
@property (nonatomic, copy, readonly) NSNumber *lng;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSNumber *open24HrsToday;
@property (nonatomic, copy, readonly) NSNumber *openNow;
@property (nonatomic, copy, readonly) NSString *phone;
@property (nonatomic, copy, readonly) NSString *store;
@property (nonatomic, copy, readwrite) NSNumber *distance;

@end
