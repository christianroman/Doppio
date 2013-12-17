//
//  Address.h
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Address : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *streetAddressLine1;
@property (nonatomic, copy, readonly) NSString *streetAddressLine2;
@property (nonatomic, copy, readonly) NSString *streetAddressLine3;
@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *countrySubdivisionCode;
@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *postalCode;

@end
