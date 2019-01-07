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
#import "FKSingleTask.h"
#import "FKResumeHelper.h"
#import "NSString+FKDownload.h"
#import "NSURLSessionDownloadTask+FKDownload.h"

@implementation FKDownloadExecutor

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.manager.configure.backgroundHandler) {
        self.manager.configure.backgroundHandler();
        self.manager.configure.backgroundHandler = nil;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            return;
        }
    }
    
    NSString *identifier = [(NSURLSessionDownloadTask *)task fkidentifier];
    NSInteger idx = [(NSURLSessionDownloadTask *)task idx];
    id<FKTaskProtocol> dt = [[FKDownloadManager manager] acquireTaskWithIdentifier:identifier];
    switch (dt.type) {
        case FKTaskTypeSingle: {
            [self singleTask:dt didCompleteWithError:error];
        } break;
            
        case FKTaskTypeGroup: {
            [self groupTask:dt idx:idx didCompleteWithError:error];
        } break;
            
        case FKTaskTypeDrip: {
            [self dripTask:dt idx:idx didCompleteWithError:error];
        } break;
    }
    
    /*
    if (dt) {
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                if (resumeData) {
                    // 暂停
                    NSString *resumeDataPath = [[dt.identifier taskDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dtr", dt.identifier]];
                    [resumeData writeToFile:resumeDataPath atomically:YES];
                    
                    NSString *dttPath = [[dt.identifier taskDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dtt", dt.identifier]];
                    NSString *sysTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp", [(FKSingleTask *)dt tmp]]];
                    [[NSFileManager defaultManager] moveItemAtPath:dttPath toPath:sysTmpPath error:nil];
                } else {
                    // 取消
                }
            } else {
                // 错误
            }
        } else {
            // 完成
            [(FKSingleTask *)dt sendSuccess];
        }
    } else {
        // 任务不存在, 保存必要文件以备用
    }
     */
    
    /*
    if (task.currentRequest.URL.absoluteString.length == 0) {
        return;
    }
    
    FKTask *downloadTask = [[FKDownloadManager manager] acquire:task.currentRequest.URL.absoluteString.decodeEscapedString];
    if (downloadTask == nil) {
        // !!!: kill app 后可能有任务会被系统取消, 再次启动时将恢复数据保存到默认文件中.
        if (error.code == NSURLErrorCancelled && error.userInfo[NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            NSString *identifier = task.currentRequest.URL.absoluteString.identifier;
            NSString *resumeFielPath = [[FKDownloadManager manager].configure.resumeSavePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.resume", identifier]];
            [[FKResumeHelper correctResumeData:resumeData] writeToFile:resumeFielPath atomically:YES];
        }
        return;
    }
    
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
                if ([FKResumeHelper checkUsable:resumeData]) {
                    [downloadTask setValue:[FKResumeHelper correctResumeData:resumeData] forKey:@"resumeData"];
                }
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
     */
}

- (void)singleTask:(FKSingleTask *)task didCompleteWithError:(NSError *)error {
    if (task) {
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                if (resumeData) {
                    // 暂停
                    NSString *resumeDataPath = [[task.identifier taskDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dtr", task.identifier]];
                    [resumeData writeToFile:resumeDataPath atomically:YES];
                    
                    NSString *dttPath = [[task.identifier taskDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dtt", task.identifier]];
                    NSString *sysTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp", [task tmp]]];
                    [[NSFileManager defaultManager] moveItemAtPath:dttPath toPath:sysTmpPath error:nil];
                } else {
                    // 取消
                }
            } else {
                // 错误
            }
        } else {
            // 完成
            [task sendSuccess];
        }
    } else {
        // 任务不存在, 保存必要文件以备用
    }
}

- (void)groupTask:(FKSingleTask *)task idx:(NSInteger)idx didCompleteWithError:(NSError *)error {
    
}

- (void)dripTask:(FKSingleTask *)task idx:(NSInteger)idx didCompleteWithError:(NSError *)error {
    
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *link = downloadTask.originalRequest.URL.absoluteString;
    id<FKTaskProtocol> dt = [[FKDownloadManager manager] acquireTaskWithIdentifier:link.SHA256];
    if (dt) {
        NSString *filePath = [[dt.identifier taskDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", dt.identifier, [[downloadTask.response suggestedFilename] componentsSeparatedByString:@"."].lastObject]];
        [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:filePath error:nil];
    } else {
        
    }
    
    /*
    [[FKDownloadManager manager] setupPath];
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    if (task == nil) {
        return;
    }
    
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
     */
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    /*
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    task.progress.completedUnitCount = fileOffset;
     */
}

@end
