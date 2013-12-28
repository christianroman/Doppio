//
//  ObjectBuilder.m
// Doppio
//
//  Created by Christian Roman on 20/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "ObjectBuilder.h"
#import <Mantle/Mantle.h>

@implementation ObjectBuilder

+ (instancetype)builder
{
    static dispatch_once_t onceQueue;
    static ObjectBuilder *__builder = nil;
    dispatch_once(&onceQueue, ^{
        __builder = [[ObjectBuilder alloc] init];
    });
    
    return __builder;
}

- (id)objectFromJSON:(NSDictionary *)JSON className:(NSString *)className
{
    NSParameterAssert(className);
    
    NSError *error = nil;
    id model = [MTLJSONAdapter modelOfClass:NSClassFromString(className) fromJSONDictionary:JSON error:&error];
    
    if (!error) {
        return model;
    } else {
        return nil;
    }
}

- (id)collectionFromJSON:(NSDictionary *)JSON className:(NSString *)className
{
    NSParameterAssert(className);
    
    if ([JSON isKindOfClass:[NSArray class]]) {
        
        NSValueTransformer *valueTransformer = [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:NSClassFromString(className)];
        NSArray *collection = [valueTransformer transformedValue:JSON];
        return collection;
        
    }
    return nil;
}

@end
