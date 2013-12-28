//
//  WilcardGestureRecognizer.h
// Doppio
//
//  Created by Christian Roman on 24/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UIGestureRecognizer

@property(nonatomic, copy) TouchesEventBlock touchesBeganCallback;

@end
