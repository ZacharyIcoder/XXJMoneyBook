//
//  URLSessionManager.h
//  iHealthS
//
//  Created by Wu on 2019/3/23.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^urlSessionFinishedBlock)(NSDictionary * response);

NS_ASSUME_NONNULL_BEGIN

@interface URLSessionManager : NSObject

+ (instancetype)shared;

- (void)requestURL:(NSString *)url method:(NSString *)method params:(NSDictionary *)params dataCompletion:(void (^) (NSData *))completion;
- (void)requestURL:(NSString *)url method:(NSString *)method params:(NSDictionary *)params completion:(urlSessionFinishedBlock)completion;

@end

NS_ASSUME_NONNULL_END
