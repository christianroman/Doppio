//
//  CoffeeMeClient.h
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "AFNetworking.h"

@interface CoffeeMeClient : AFHTTPClient

- (void)enqueueUserRequestWithMethod:(NSString *)method Path:(NSString *)path parameters:(NSDictionary *)parameters resultClass:(Class)resultClass;

@end
