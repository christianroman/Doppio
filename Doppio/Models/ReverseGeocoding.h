//
//  ReverseGeocoding.h
//  Cajeros MX
//
//  Created by Christian Roman on 05/02/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface ReverseGeocoding : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) CLLocation *location;

@end
