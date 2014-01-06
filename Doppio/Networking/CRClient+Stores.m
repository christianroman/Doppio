//
//  CRClient+Stores.m
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "CRClient+Stores.h"
#import "CRClient+Requests.h"
#import "Store.h"
#import "ObjectBuilder.h"

@implementation CRClient (Stores)

- (NSURLSessionDataTask *)getNearbyStoresFromLatitude:(double)latitude
                                            longitude:(double)longitude
                                           completion:(CRArrayCompletionBlock)completion
{
    NSParameterAssert(latitude);
    NSParameterAssert(longitude);
    
    NSDictionary *parameters = @{
                                 @"languagePreference" : @"en",
                                 @"detailLevel": @2,
                                 @"format" : @"json",
                                 @"radius" : @10,
                                 @"unit" : @1,
                                 @"limit" : @300,
                                 @"longitude" : @(longitude),
                                 @"latitude": @(latitude),
                                 @"brand" : @"starbucks"
                                 };
    
    NSString *path = @"locationBeta/stores/facilities/lite";
    
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    return [self GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (!completion) {
            return;
        }
        
        if (responseObject) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                id collection = [[ObjectBuilder builder] collectionFromJSON:responseObject className:NSStringFromClass([Store class])];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(collection, nil);
                });
                
            });
            
        } else {
            completion(nil, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (completion) {
            completion(nil, error);
        }
        
    }];
}

@end
