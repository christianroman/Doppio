//
//  CoffeeMeClient.m
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "CoffeeMeClient.h"

@implementation CoffeeMeClient

static NSString * const kCoffeeMeAPIBaseURLString = @"https://test.openapi.starbucks.com/v1/";

#pragma mark - Class Methods
+ (instancetype)sharedInstance {
    static dispatch_once_t onceQueue;
    static CoffeeMeClient *__sharedInstance = nil;
    dispatch_once(&onceQueue, ^{
        __sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kCoffeeMeAPIBaseURLString]];
        
        [__sharedInstance registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [__sharedInstance setDefaultHeader:@"Accept" value:@"application/json"];
        
    });
    return __sharedInstance;
}

/*
- (void)enqueueRequestWithMethod:(NSString *)method
                                path:(NSString *)path
                          parameters:(NSDictionary *)parameters
                         resultClass:(Class)resultClass
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:method path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:parameters]; // *
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    operation
    
    [self enqueueHTTPRequestOperation:operation];
    
}
 */
 
/*
- (RACSignal *)enqueueRequest:(NSURLRequest *)request resultClass:(Class)resultClass {
    return [self enqueueRequest:request resultClass:resultClass fetchAllPages:YES];
}
*/
 
@end
