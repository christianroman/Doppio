//
//  UIColor+Utilities.m
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)

+ (instancetype)colorWithHex:(UInt32)hex
{
    return [UIColor colorWithHex:hex andAlpha:1];
}

+ (instancetype)colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0 green:((hex >> 8) & 0xFF) / 255.0 blue:(hex & 0xFF) / 255.0 alpha:alpha];
}

@end
