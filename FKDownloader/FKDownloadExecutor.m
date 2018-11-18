//
//  FKDownloadExecutor.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKDownloadExecutor.h"
#import "FKDownloadManager.h"
#import "FKConfigure.h"
#import "FKTask.h"

@implementation FKDownloadExecutor

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.manager.configure.backgroundHandler) {
        self.manager.configure.backgroundHandler();
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (task.currentRequest.URL.absoluteString.length == 0) {
        return;
    }
    
    FKTask *downloadTask = [[FKDownloadManager manager] acquire:task.currentRequest.URL.absoluteString];
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorUnknown
                                             userInfo:@{NSFilePathErrorKey: task.currentRequest.URL.absoluteString,
                                                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Status Code: %d", (int)statusCode]}];
            [downloadTask sendErrorInfo:error];
            return;
        }
    }
    
    if (error) {
        if (error.code == NSURLErrorCancelled) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                // 取消, 带恢复数据
                [resumeData writeToFile:[downloadTask resumeFilePath] atomically:YES];
                [downloadTask sendSuspendInfo];
            } else {
                // 取消
                [downloadTask sendCancelldInfo];
            }
        } else {
            [downloadTask sendErrorInfo:error];
        }
    }
    
    [[FKDownloadManager manager] startNextIdleTask];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    [[FKDownloadManager manager] setupPath];
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)downloadTask.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorUnknown
                                             userInfo:@{NSFilePathErrorKey: downloadTask.currentRequest.URL.absoluteString,
                                                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Status Code: %d", (int)statusCode]}];
            [task sendErrorInfo:error];
            return;
        }
    }
    
    if ([[FKDownloadManager manager].fileManager fileExistsAtPath:location.path]) {
        // TODO: 为防止检验中途文件被删除, 所以需将文件转移后开始校验
        if ([[FKDownloadManager manager].fileManager fileExistsAtPath:task.filePath]) {
            [task sendFinishInfo];
        } else {
            NSError *error;
            [[FKDownloadManager manager].fileManager copyItemAtPath:location.path toPath:task.filePath error:&error];
            if (error) {
                [task sendErrorInfo:error];
            } else {
                if ([task checksum]) {
                    [task sendFinishInfo];
                } else {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                         code:NSURLErrorUnknown
                                                     userInfo:@{NSFilePathErrorKey: task.url,
                                                                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"File verification failed"]}];
                    [task sendErrorInfo:error];
                }
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                             code:2
                                         userInfo:@{NSFilePathErrorKey: location.path,
                                                    NSLocalizedDescriptionKey: @"The operation couldn’t be completed. No such file or directory"}];
        [task sendErrorInfo:error];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    task.progress.completedUnitCount = fileOffset;
}

@end
