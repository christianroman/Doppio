//
//  Coordinates.h
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Coordinates : MTLModel

@property (nonatomic, copy, readonly) NSNumber *latitude;
@property (nonatomic, copy, readonly) NSNumber *longitude;

@end
