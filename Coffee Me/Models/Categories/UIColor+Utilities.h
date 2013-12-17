//
//  UIColor+Utilities.h
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)

+ (instancetype)colorWithHex:(UInt32)hex;
+ (instancetype)colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;

@end
