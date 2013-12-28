//
//  ObjectBuilder.h
// Doppio
//
//  Created by Christian Roman on 20/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectBuilder : NSObject

+ (instancetype)builder;
- (id)objectFromJSON:(NSDictionary *)JSON className:(NSString *)className;
- (id)collectionFromJSON:(NSDictionary *)JSON className:(NSString *)className;

@end
