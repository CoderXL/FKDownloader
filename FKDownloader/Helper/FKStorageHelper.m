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

@implementation FKStorageHelper

+ (void)saveTask:(id<FKTaskProtocol>)task {
    switch (task.type) {
        case FKTaskTypeSingle: {
            FKSingleTask *singleTask = (FKSingleTask *)task;
            
            FKSingleTaskInfo info;
            info.base.number = singleTask.number;
            info.base.type = singleTask.type;
            strcpy(info.base.identifier, [singleTask.identifier cStringUsingEncoding:NSUTF8StringEncoding]);
            strcpy(info.link, [singleTask.link cStringUsingEncoding:NSUTF8StringEncoding]);
            info.length = singleTask.length;
            strcpy(info.tmp, [singleTask.tmp cStringUsingEncoding:NSUTF8StringEncoding]);
            
            NSString *dtiPath = [singleTask.taskDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dti", singleTask.identifier]];
            FILE *fp = fopen(dtiPath.UTF8String, "wd");
            fwrite(&info, sizeof(FKSingleTaskInfo), 1, fp);
            fclose(fp);
            
        } break;
            
        case FKTaskTypeGroup: {
            
        } break;
            
        case FKTaskTypeDrip: {
            
        } break;
    }
}

@end
