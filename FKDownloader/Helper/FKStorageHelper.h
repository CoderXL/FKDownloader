//
//  FKStorageHelper.h
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKTaskProtocol.h"

typedef struct FKTaskBaseInfo {
    uint64_t number;
    char identifier[65];
    long type;
} FKTaskBaseInfo;

typedef struct FKGroupTaskComponent {
    char link[4096];
    uint64_t length;
    char tmp[64];
} FKGroupTaskComponent;

typedef struct FKDripTaskComponent {
    uint64_t idx;
    uint16_t start;
    uint16_t end;
    char tmp[64];
} FKDripTaskComponent;

typedef struct FKSingleTaskInfo {
    FKTaskBaseInfo base;
    uint64_t length;
    char link[4096];
    char tmp[64];
} FKSingleTaskInfo;

typedef struct FKGroupTaskInfo {
    FKTaskBaseInfo base;
    FKGroupTaskComponent *components;
} FKGroupTaskInfo;

typedef struct FKDripTaskInfo {
    FKTaskBaseInfo base;
    FKDripTaskComponent *components;
} FKDripTaskInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FKStorageHelper : NSObject

+ (void)saveTask:(id<FKTaskProtocol>)task;
+ (id<FKTaskProtocol>)loadTaskWithIdentifier:(NSString *)identifier;

//+ (void)saveResumeDataWithTask:(id<FKTaskProtocol>)task;
//+ (void)loadResumeDataWithTask:(id<FKTaskProtocol>)task;

@end

NS_ASSUME_NONNULL_END
