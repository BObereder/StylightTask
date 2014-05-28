//
//  STLWebService.h
//  StylightTask
//
//  Created by Bernhard Obereder on 12.05.14.
//  Copyright (c) 2014 Bernhard Obereder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

typedef NS_ENUM(NSInteger, HttpMethod)
{
    GET,
    POST,
    PUT,
    DELETE
};

@interface STLWebService : NSObject

@property(nonatomic,readonly) int batchsize;
+ (STLWebService *)sharedService;

- (NSURLSessionDataTask *)retrievBlocksForPage:(int)page WithCompletionBlock:(void (^)(NSError *error))block;

@end
