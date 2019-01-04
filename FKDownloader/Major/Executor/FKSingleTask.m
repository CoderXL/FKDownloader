//
//  FKSingleTask.m
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "FKSingleTask.h"
#import "FKDownloadManager.h"
#import "FKStorageHelper.h"

@interface FKSingleTask ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation FKSingleTask
@synthesize link = _link;
@synthesize number = _number;
@synthesize type = _type;

- (void)start {
    if (self.link.length) {
        self.downloadTask = [self.manager.session downloadTaskWithURL:[NSURL URLWithString:self.link]];
        [self.downloadTask resume];
        [FKStorageHelper saveTask:self];
    }
}

- (void)suspend {
    if (self.downloadTask) {
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
        }];
    }
}

- (void)resume {
    self.downloadTask = [self.manager.session downloadTaskWithResumeData:[NSData data]];
    [self.downloadTask resume];
}

- (void)cancel {
    [self.downloadTask cancel];
}

#pragma mark - Getter/setter


@end
