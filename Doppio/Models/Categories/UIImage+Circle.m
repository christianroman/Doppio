//
//  UIImage+Circle.m
// Doppio
//
//  Created by Christian Roman on 26/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "UIImage+Circle.h"

@implementation UIImage (Circle)

+ (instancetype)circleImageWithSize:(int)size color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size, size)];
    CGContextAddPath(context, circle.CGPath);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    UIImage *circleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circleImage;
}

@end
