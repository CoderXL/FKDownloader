//
// Created by norld on 2019-01-02.
// Copyright (c) 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FKHubProtocol <NSObject>

@required
- (void)addObj:(id)obj withKey:(NSString *)key;
- (void)removeObjOfKey:(NSString *)key;

- (NSArray *)allObjs;
- (BOOL)containObj:(id)obj;
- (NSUInteger)countOfObjs;

@end

NS_ASSUME_NONNULL_END
