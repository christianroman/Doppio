//
//  WilcardGestureRecognizer.m
// Doppio
//
//  Created by Christian Roman on 24/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "WilcardGestureRecognizer.h"

@implementation WildcardGestureRecognizer

- (id) init
{
    if (self = [super init]) {
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchesBeganCallback) {
        self.touchesBeganCallback(touches, event);
    }
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end
