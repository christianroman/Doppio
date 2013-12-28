//
//  CRClient+Requests.h
// Doppio
//
//  Created by Christian Roman on 20/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "CRClient.h"
#import "CRCompletionBlocks.h"

@interface CRClient (Requests)

- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                 completion:(CRResponseCompletionBlock)completion;

@end
