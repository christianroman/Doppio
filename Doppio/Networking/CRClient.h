//
//  CRClient.h
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "AFNetworking.h"

@interface CRClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
