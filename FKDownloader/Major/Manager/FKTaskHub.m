//
//  FKTaskHub.m
//  FKDownloaderDemo
//
//  Created by norld on 2019/1/6.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "FKTaskHub.h"

@interface FKTaskHub ()

@property (nonatomic, copy  ) NSMutableSet *objs;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, id<FKTaskProtocol>> *map;

@end

@implementation FKTaskHub

+ (instancetype)hub {
    static FKTaskHub *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[FKTaskHub alloc] init];
    });
    return _instance;
}

- (id<FKTaskProtocol>)objWithKey:(NSString *)key {
    @synchronized (self.objs) {
        return [self.map objectForKey:key];
    }
}

- (void)addObj:(id<FKTaskProtocol>)obj withKey:(NSString *)key {
    @synchronized (self.objs) {
        [self.objs addObject:obj];
        [self.map setObject:obj forKey:key];
    }
}

- (void)removeObjOfKey:(NSString *)key {
    @synchronized (self.objs) {
        id<FKTaskProtocol> obj = [self.map objectForKey:key];
        if (obj) {
            [self.objs removeObject:obj];
            [self.map removeObjectForKey:key];
        }
    }
}

- (NSArray *)allObjs {
    @synchronized (self.objs) {
        return self.objs.allObjects;
    }
}

- (BOOL)containObj:(id<FKTaskProtocol>)obj {
    @synchronized (self.objs) {
        return [self.objs containsObject:obj];
    }
}

- (NSUInteger)countOfObjs {
    @synchronized (self.objs) {
        return [self.objs count];
    }
}


#pragma mark - Getter/Setter
- (NSMutableSet *)objs {
    if (!_objs) {
        _objs = [[NSMutableSet alloc] init];
    }
    return _objs;
}

- (NSMutableDictionary<NSString *,id<FKTaskProtocol>> *)map {
    if (!_map) {
        _map = [NSMutableDictionary dictionary];
    }
    return _map;
}


@end
