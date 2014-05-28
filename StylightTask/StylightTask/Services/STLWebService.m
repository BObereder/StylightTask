//
//  STLWebService.m
//  StylightTask
//
//  Created by Bernhard Obereder on 12.05.14.
//  Copyright (c) 2014 Bernhard Obereder. All rights reserved.
//

#import "STLWebService.h"
#import "STLItem.h"

#define StylightBaseURLString @"http://api.stylight.com"
#define BATCHSIZE 20

@interface STLWebService ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end


NSString* const STLStatusOK = @"SUCCESS";
NSString* const STLAPIKey = @"D13A5A5A0A3602477A513E02691A8458";

@implementation STLWebService

@synthesize batchsize = _batchsize;

+ (STLWebService *)sharedService
{
    static STLWebService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      instance = [[STLWebService alloc] init];
                  });
    return instance;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _batchsize = BATCHSIZE;
        self.httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:StylightBaseURLString]];
        
        self.httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.httpSessionManager.requestSerializer setValue:STLAPIKey forHTTPHeaderField:@"X-apiKey"];
        self.httpSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}


- (NSURLSessionDataTask *)httpRequest:(HttpMethod)method
                                 path:(NSString *)path
                              content:(id)content
                      completionBlock:(void (^)(NSError *error, id data))block
{
    // SUCCESS
    void (^success)(NSURLSessionDataTask *task, id responseObject) = ^void (NSURLSessionDataTask *task, id responseObject)
    {
        NSString *status = responseObject[@"status"];
        
        // Status code failed
        if (status != nil && ![status isEqualToString:STLStatusOK])
        {
            // TODO: Something went wrong. Do error handling
            block([NSError errorWithDomain:@"STL_ERROR_DOMAIN" code:999 userInfo:nil], nil);
        }
        
        // Everything OK
        else if (block)
        {
            block(nil, responseObject);
        }
    };
    
    
    // FAILURE
    void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^void (NSURLSessionDataTask *task, NSError *error)
    {
        if (block)
        {
            block(error, nil);
        }
    };
    
    
    
    switch(method)
    {
        case GET:
            return [self.httpSessionManager GET:path parameters:content success:success failure:failure];
            break;
        case POST:
            return [self.httpSessionManager POST:path parameters:content success:success failure:failure];
            break;
        case PUT:
            return [self.httpSessionManager PUT:path parameters:content success:success failure:failure];
            break;
        case DELETE:
            return [self.httpSessionManager DELETE:path parameters:content success:success failure:failure];
            break;
            
        default:
            return [self.httpSessionManager GET:path parameters:content success:success failure:failure];
            break;
    }
}

- (NSURLSessionDataTask *)retrievBlocksForPage:(int)page WithCompletionBlock:(void (^)(NSError *))block
{

    
    NSDictionary *parameters =@{@"gender" : @"women",
                                @"initializeBoards" : @"true",
                                @"initializeRows" : @"1024000",
                                @"pageItems" : [[NSNumber numberWithInt:self.batchsize] stringValue],
                                @"page" : [NSString stringWithFormat:@"%i",page]
                                };
    
    
    return [self httpRequest:GET
                        path:@"api/new"
                     content:parameters
             completionBlock:^(NSError *error, id data)
            {
                if (!error) {
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                        
                        NSArray *items = data[@"items"];
                        
                        for (NSDictionary *item in items) {
                            
                            // distinguish between board and product
                            
                            //board
                            if (!(item[@"board"] == [NSNull null]))
                            {
                                NSDictionary *board = item[@"board"];
                                
                                STLItem *dbItem = [STLItem MR_createInContext:localContext];
                                
                                dbItem.name = board[@"title"];
                            
                                dbItem.imageURL =[NSString stringWithFormat:@"http:%@",board[@"coverImage"]];
                                
                                NSDictionary *creator = board[@"creator"];
                                dbItem.creator = [NSString  stringWithFormat:@"%@ %@",creator[@"firstname"],creator[@"lastname"]];
                                dbItem.timeStamp = [NSDate date];
                            }
                            
                            //product
                            else if(!(item[@"product"] == [NSNull null]))
                            {
                                NSDictionary *product = item[@"product"];
                                
                                STLItem *dbItem = [STLItem MR_createInContext:localContext];
                                
                                dbItem.name = product[@"name"];
                                
                                NSArray *images = product[@"images"];
                                NSDictionary *image = images[0];
                                dbItem.imageURL = image[@"url"];
                                dbItem.creator = nil;
                                dbItem.timeStamp = [NSDate date];
                            }
                            
                        }
                        
                    } completion:^(BOOL success, NSError *error) {
                        if (block)
                        {
                            block(error);
                        }
                    }];
                }
                else if (block)
                {
                    block(error);
                }
            }];
    
}

@end
