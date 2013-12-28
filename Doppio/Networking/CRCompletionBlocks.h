//
//  CRCompletionBlocks.h
// Doppio
//
//  Created by Christian Roman on 20/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

typedef void (^CRCompletionBlock)(NSError *error);

typedef void (^CRResponseCompletionBlock)(NSHTTPURLResponse *response, id responseObject, NSError *error);

typedef void (^CRBooleanCompletionBlock)(BOOL result, NSError *error);

typedef void (^CRObjectCompletionBlock)(id object, NSError *error);

typedef void (^CRArrayCompletionBlock)(NSArray *collection, NSError *error);
