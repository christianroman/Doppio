//
//  Store.m
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "Store.h"

@implementation Store

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"address1" : @"Addr1",
             @"address2" : @"Addr3",
             @"features" : @"Features",
             @"ID": @"Id",
             @"lat" : @"Lat",
             @"lng" : @"Long",
             @"name" : @"Name",
             @"open24HrsToday" : @"Open24HrsToday",
             @"openNow" : @"OpenNow",
             @"phone" : @"Phone",
             @"store" : @"Store"
             };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, ID: %@, name: %@>", NSStringFromClass([self class]), self, self.ID, self.name];
}

@end
