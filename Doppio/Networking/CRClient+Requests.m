//
//  CRClient+Requests.m
// Doppio
//
//  Created by Christian Roman on 20/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "CRClient+Requests.h"

@implementation CRClient (Requests)

- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters
                                 completion:(CRResponseCompletionBlock)completion
{
    NSParameterAssert(method);
    NSParameterAssert(path);
    
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    NSError *error;
    NSURLRequest *request = [[self requestSerializer] requestWithMethod:method URLString:URLString parameters:parameters error:&error];
    
    if(!error) {
        NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (completion) {
                completion((NSHTTPURLResponse *)response, responseObject, error);
            }
        }];
        
        [task resume];
        return task;
    }
    
    return nil;
}

@end
