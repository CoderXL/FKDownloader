//
//  FKTaskHub.h
//  FKDownloaderDemo
//
//  Created by norld on 2019/1/6.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKHubProtocol.h"
#import "FKTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKTaskHub : NSObject<FKHubProtocol>

+ (instancetype)hub;

- (nullable id<FKTaskProtocol>)objWithKey:(NSString *)key;
- (void)addObj:(id<FKTaskProtocol>)obj withKey:(NSString *)key;
- (void)removeObjOfKey:(NSString *)key;

- (NSArray *)allObjs;
- (BOOL)containObj:(id<FKTaskProtocol>)obj;
- (NSUInteger)countOfObjs;

@end

NS_ASSUME_NONNULL_END
