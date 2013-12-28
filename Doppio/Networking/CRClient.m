//
//  CRClient.m
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "CRClient.h"

@interface CRClient ()

@property (nonatomic, strong) NSString *userAgent;

+ (NSURL *)APIBaseURL;

@end

@implementation CRClient

static NSString * const kCRClientAPIBaseURLString = @"http://api.starbucks.com/";

#pragma mark - Class Methods

+ (instancetype)sharedClient
{
    static dispatch_once_t onceQueue;
    static CRClient *__sharedClient = nil;
    dispatch_once(&onceQueue, ^{
        __sharedClient = [[self alloc] init];
    });
    return __sharedClient;
}

- (id)init
{
    if (self = [super initWithBaseURL:[[self class] APIBaseURL]])
    {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:@"d3ub5Uchuba28phavu32b62ratreveku" password:@"sawr5DEthaPHeyes"];
        [self.requestSerializer setValue:@"Starbucks/2.6.1 CFNetwork/672.0.2 Darwin/14.0.0" forHTTPHeaderField:@"User-Agent"];
    }
    
    return self;
}

+ (NSURL *)APIBaseURL
{
    return [NSURL URLWithString:kCRClientAPIBaseURLString];
}
 
@end
