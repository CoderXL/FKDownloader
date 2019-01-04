//
//  FKStorageHelper.m
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "FKStorageHelper.h"
#import "FKSingleTask.h"

/**
 任务 -> 文件
 - task.identifier
 |- task.identifier.dti
 |- task.tmp
 |- task.identifier.{idx}.trd
 |- task.identifier.file[s]
 
 任务信息
 - single
 number
 sha256(link)
 type
 length
 tmp
 
 - group
 number
 sha256(name)
 type
 tasks[
    link
    length
    tmp
 ]
 
 - drip
 number
 sha256(link)
 type
 length
 drip[
    idx
    start
    end
    tmp
 ]
 */

typedef struct FKTaskBaseInfo {
    uint64_t number;
    char *identifier;
    long type;
} FKTaskBaseInfo;

typedef struct FKGroupTaskComponent {
    char *link;
    uint64_t length;
    char *tmp;
} FKGroupTaskComponent;

typedef struct FKDripTaskComponent {
    uint64_t idx;
    uint16_t start;
    uint16_t end;
    char *tmp;
} FKDripTaskComponent;

typedef struct FKSingleTaskInfo {
    FKTaskBaseInfo base;
    uint64_t length;
    char *tmp;
} FKSingleTaskInfo;

typedef struct FKGroupTaskInfo {
    FKTaskBaseInfo base;
    FKGroupTaskComponent *components;
} FKGroupTaskInfo;

typedef struct FKDripTaskInfo {
    FKTaskBaseInfo base;
    FKDripTaskComponent *components;
} FKDripTaskInfo;

@implementation FKStorageHelper

+ (void)saveTask:(id<FKTaskProtocol>)task {
    switch (task.type) {
        case FKTaskTypeSingle: {
            FKSingleTask *singleTask = (FKSingleTask *)task;
            
            FKSingleTaskInfo info;
            info.base.number = singleTask.number;
            info.base.identifier = strdup(singleTask.identifier.UTF8String);
            info.base.type = singleTask.type;
            info.length = singleTask.length;
            info.tmp = strdup(singleTask.tmp.UTF8String);
        } break;
            
        case FKTaskTypeGroup: {
            
        } break;
            
        case FKTaskTypeDrip: {
            
        } break;
    }
}

@end
