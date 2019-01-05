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
#import "FKResumeHelper.h"
#import "NSString+FKDownload.h"

typedef void(^poll)(uint64_t length, int idx);
void pollingLength(NSArray *links, poll p, dispatch_block_t finish) {
    __block int count = 0;
    for (int i = 0; i < links.count; i++) {
        NSString *link = [links objectAtIndex:i];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
        request.HTTPMethod = @"HEAD";
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSNumber *length = @(0);
            if ([response respondsToSelector:@selector(allHeaderFields)]) {
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                NSDictionary *header = res.allHeaderFields;
                NSNumber *temp = [[NSNumberFormatter new] numberFromString:[header valueForKey:@"Content-Length"]];
                if (temp) { length = temp; }
                @synchronized (links) {
                    count++;
                    if (count == i) {
                        if (finish) {
                            finish();
                        }
                    }
                }
            }
            if (p) {
                p(length.unsignedLongLongValue, i);
            }
        }] resume];
    }
}

@interface FKSingleTask ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSProgress *taskProgress;
@property (nonatomic, assign, getter=isTempFileNameSaved) BOOL tempFileNameSaved;

@end

@implementation FKSingleTask
@synthesize link = _link;
@synthesize identifier = _identifier;
@synthesize number = _number;
@synthesize type = _type;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = FKTaskTypeSingle;
    }
    return self;
}

- (void)start {
    // 创建 task
    // 获取 tmp 文件名
    // 获取 length
    // 真正开始
    // 保存信息
    self.downloadTask = [self.manager.session downloadTaskWithURL:[NSURL URLWithString:self.link]];
    [self.downloadTask resume];
    [self.downloadTask addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) options:NSKeyValueObservingOptionNew context:nil];
    [self.downloadTask addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) options:NSKeyValueObservingOptionNew context:nil];
    if (self.status) {
        self.status();
    }
}

- (void)suspend {
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (resumeData) {
            self.resumeData = resumeData;
            [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) context:nil];
            [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) context:nil];
        }
    }];
    if (self.status) {
        self.status();
    }
}

- (void)resume {
    self.downloadTask = [self.manager.session downloadTaskWithResumeData:self.resumeData];
    [self.downloadTask resume];
    [self.downloadTask addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) options:NSKeyValueObservingOptionNew context:nil];
    [self.downloadTask addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) options:NSKeyValueObservingOptionNew context:nil];
    if (self.status) {
        self.status();
    }
}

- (void)cancel {
    [self.downloadTask cancel];
    if (self.status) {
        self.status();
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
        if (self.isTempFileNameSaved == NO) {
            self.tempFileNameSaved = YES;
            [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (resumeData) {
                    self.resumeData = resumeData;
                    [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) context:nil];
                    [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) context:nil];
                    NSDictionary *resumeDic = [FKResumeHelper readResumeData:resumeData];
                    if ([resumeDic.allKeys containsObject:FKResumeDataInfoTempFileName]) {
                        self.tmp = [resumeDic objectForKey:FKResumeDataInfoTempFileName];
                    }
                    if ([resumeDic.allKeys containsObject:FKResumeDataInfoLocalPath]) {
                        self.tmp = [[resumeDic objectForKey:FKResumeDataInfoLocalPath] componentsSeparatedByString:@"/"].lastObject;
                    }
                    self.length = self.downloadTask.countOfBytesExpectedToReceive;
                    [self resume];
                    [FKStorageHelper saveTask:self];
                }
            }];
        }
    }
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
        // progress
        self.taskProgress.completedUnitCount = self.downloadTask.countOfBytesReceived;
        if (self.progress) {
            self.progress();
        }
    }
}

- (void)obWithSt:(FKStatusBlock)st
            prog:(FKProgressBlock)prog
         success:(FKSuccessBlock)success
           faild:(FKFaildBlock)faild {
    
    self.status = st;
    self.progress = prog;
    self.success = success;
    self.faild = faild;
}

#pragma mark - Getter/setter
- (void)setLink:(NSString *)link {
    _link = link;
    
    self.identifier = [link SHA256];
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *taskDir = [rootPath stringByAppendingPathComponent:self.identifier];
    if ([self.manager.fileManager fileExistsAtPath:taskDir] == NO) {
        [self.manager.fileManager createDirectoryAtPath:taskDir withIntermediateDirectories:YES attributes:nil error:nil];
        self.taskDir = taskDir;
    }
}

- (NSProgress *)taskProgress {
    if (!_taskProgress) {
        _taskProgress = [NSProgress progressWithTotalUnitCount:1];
    }
    return _taskProgress;
}

@end
