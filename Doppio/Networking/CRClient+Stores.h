//
//  CRClient+Stores.h
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "CRClient.h"
#import "CRCompletionBlocks.h"

@interface CRClient (Stores)

- (NSURLSessionDataTask *)getNearbyStoresFromLatitude:(double)latitude
                                            longitude:(double)longitude
                                           completion:(CRArrayCompletionBlock)completion;

@end
