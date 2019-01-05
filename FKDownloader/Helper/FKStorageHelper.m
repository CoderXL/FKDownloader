//
//  FKStorageHelper.m
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "FKStorageHelper.h"
#import "FKSingleTask.h"
#import "FKDownloadManager.h"
#import "FKConfigure.h"

@implementation FKStorageHelper

+ (void)saveTask:(id<FKTaskProtocol>)task {
    NSString *taskDir = [[FKDownloadManager manager].configure.rootPath stringByAppendingPathComponent:task.identifier];
    BOOL isDirectory = NO;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:taskDir isDirectory:&isDirectory];
    if (!(isFileExist && isDirectory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:taskDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
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
            strcpy(info.ext, [singleTask.ext cStringUsingEncoding:NSUTF8StringEncoding]);
            
            NSString *dtiPath = [taskDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dti", singleTask.identifier]];
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
