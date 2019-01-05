//
//  FKStorageHelper.m
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "FKStorageHelper.h"
#import "FKSingleTask.h"

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
            info.base.length = singleTask.length;
            strcpy(info.tmp, [singleTask.tmp cStringUsingEncoding:NSUTF8StringEncoding]);
            
            NSString *dtiPath = [singleTask.taskDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dti", singleTask.identifier]];
            FILE *fp = fopen(dtiPath.UTF8String, "wb");
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
