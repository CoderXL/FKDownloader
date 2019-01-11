//
//  FKSingleTask.m
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "FKSingleTask.h"
#import "FKDownloadManager.h"
#import "FKConfigure.h"
#import "FKStorageHelper.h"
#import "FKResumeHelper.h"
#import "NSURLSessionDownloadTask+FKDownload.h"
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

@property (nonatomic, strong) NSString *link;

@property (nonatomic, copy  ) NSMutableSet<void(^)(FKSingleTask *)> *statusBlocks;
@property (nonatomic, copy  ) NSMutableSet<void(^)(FKSingleTask *)> *progressBlocks;
@property (nonatomic, copy  ) NSMutableSet<void(^)(FKSingleTask *)> *successBlocks;
@property (nonatomic, copy  ) NSMutableSet<void(^)(FKSingleTask *)> *faildBlocks;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSProgress *taskProgress;
@property (nonatomic, assign, getter=isTempFileNameSaved) BOOL tempFileNameSaved;

@end

@implementation FKSingleTask
@synthesize identifier = _identifier;
@synthesize number = _number;
@synthesize type = _type;
@synthesize status = _status;

- (instancetype)initWithLink:(NSString *)link {
    self = [super init];
    if (self) {
        self.manager = [FKDownloadManager manager];
        self.link = link;
        self.identifier = link.SHA256;
        self.type = FKTaskTypeSingle;
        if ([self loadExistFile] == NO) {
            self.number = [self.manager readAutonumber] + 1;
            [self.manager autonumberOfInc:1];
        }
    }
    return self;
}

+ (instancetype)taskWithLink:(NSString *)link {
    return [[self alloc] initWithLink:link];
}

- (NSString *)link {
    return _link;
}

- (BOOL)loadExistFile {
    NSString *taskDir = [[FKDownloadManager manager].configure.rootPath stringByAppendingPathComponent:self.identifier];
    NSString *dtiPath = [taskDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dti", self.identifier]];
    if ([self.manager.fileManager fileExistsAtPath:dtiPath]) {
        FKSingleTaskInfo info;
        FILE *fp = fopen(dtiPath.UTF8String, "rb");
        fread(&info, sizeof(FKSingleTaskInfo), 1, fp);
        fclose(fp);
        
        self.number = info.base.number;
        self.length = info.base.length;
        self.tmp = [NSString stringWithUTF8String:info.tmp];
        self.ext = [NSString stringWithUTF8String:info.ext];
        
        [self restoryFile];
        return YES;
    }
    return NO;
}

- (void)restoryFile {
    NSString *taskDir = [[FKDownloadManager manager].configure.rootPath stringByAppendingPathComponent:self.identifier];
    NSString *tmpPath = [taskDir stringByAppendingPathComponent:self.tmp];
    if ([self.manager.fileManager fileExistsAtPath:tmpPath]) {
        NSString *resumeDataPath = [taskDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dtr", self.identifier]];
        if ([self.manager.fileManager fileExistsAtPath:resumeDataPath]) {
            NSString *sysTmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.tmp];
            [self.manager.fileManager moveItemAtPath:tmpPath toPath:sysTmpPath error:nil];
            
            self.resumeData = [NSData dataWithContentsOfFile:resumeDataPath options:NSDataReadingMappedIfSafe error:nil];
            self.status = FKTaskStatusSuspend;
        } else {
            self.status = FKTaskStatusNone;
            [self.manager.fileManager removeItemAtPath:tmpPath error:nil];
        }
    } else {
        NSString *filePath = [taskDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.identifier, self.ext]];
        if ([self.manager.fileManager fileExistsAtPath:filePath]) {
            self.status = FKTaskStatusComplete;
        } else {
            self.status = FKTaskStatusNone;
            [self.manager.fileManager removeItemAtPath:tmpPath error:nil];
        }
    }
}

- (FKSingleTask *)start {
    // 创建 task
    // 获取 tmp 文件名
    // 获取 length
    // 真正开始
    // 保存信息
    if (self.status == FKTaskStatusComplete) {
        for (void(^block)(FKSingleTask *) in self.successBlocks) {
            block(self);
        }
        return self;
    }
    
    [self restoryFile];
    if (self.resumeData) {
        [self resume];
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.link]];
        if (self.userHeader) {
            [self.userHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [request setValue:obj forHTTPHeaderField:key];
            }];
        }
        [self removeProgressObserver];
        self.downloadTask = [self.manager.session downloadTaskWithRequest:request];
        self.downloadTask.fkidentifier = self.identifier;
        [self.downloadTask resume];
        [self addProgressObserver];
        self.status = FKTaskStatusExecuting;
        for (void(^block)(FKSingleTask *) in self.statusBlocks) {
            block(self);
        }
    }
    return self;
}

- (FKSingleTask *)suspend {
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (resumeData) {
            self.resumeData = resumeData;
            [self removeProgressObserver];
        }
    }];
    self.status = FKTaskStatusSuspend;
    for (void(^block)(FKSingleTask *) in self.statusBlocks) {
        block(self);
    }
    return self;
}

- (FKSingleTask *)resume {
    [self restoryFile];
    self.downloadTask = [self.manager.session downloadTaskWithResumeData:self.resumeData];
    [self.downloadTask resume];
    [self addProgressObserver];
    self.status = FKTaskStatusExecuting;
    for (void(^block)(FKSingleTask *) in self.statusBlocks) {
        block(self);
    }
    return self;
}

- (FKSingleTask *)cancel {
    [self.downloadTask cancel];
    [self removeProgressObserver];
    self.downloadTask = nil;
    self.status = FKTaskStatusNone;
    for (void(^block)(FKSingleTask *) in self.statusBlocks) {
        block(self);
    }
    return self;
}

- (void)sendSuccess {
    self.status = FKTaskStatusComplete;
    for (void(^block)(FKSingleTask *) in self.successBlocks) {
        block(self);
    }
}

- (void)sendFaild:(NSError *)error {
    self.status = FKTaskStatusFaild;
    self.error = error;
    for (void(^block)(FKSingleTask *) in self.faildBlocks) {
        block(self);
    }
}

#pragma mark - observer
- (void)addProgressObserver {
    [self.downloadTask addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) options:NSKeyValueObservingOptionNew context:nil];
    [self.downloadTask addObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeProgressObserver {
    [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived)) context:nil];
    [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) context:nil];
}

- (void)clear {
    [self removeProgressObserver];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
        if (self.isTempFileNameSaved == NO) {
            self.tempFileNameSaved = YES;
            __weak typeof(self) weak = self;
            [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                __strong typeof(weak) strong = weak;
                if (resumeData) {
                    strong.resumeData = resumeData;
                    [strong removeProgressObserver];
                    
                    NSDictionary *resumeDic = [FKResumeHelper readResumeData:resumeData];
                    if ([resumeDic.allKeys containsObject:FKResumeDataInfoTempFileName]) {
                        strong.tmp = [resumeDic objectForKey:FKResumeDataInfoTempFileName];
                    }
                    if ([resumeDic.allKeys containsObject:FKResumeDataInfoLocalPath]) {
                        strong.tmp = [[resumeDic objectForKey:FKResumeDataInfoLocalPath] componentsSeparatedByString:@"/"].lastObject;
                    }
                    strong.length = strong.downloadTask.countOfBytesExpectedToReceive;
                    strong.ext = [strong.downloadTask.response.suggestedFilename componentsSeparatedByString:@"."].lastObject;
                    [strong resume];
                    [FKStorageHelper saveTask:strong];
                }
            }];
        }
    }
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
        // progress
        self.taskProgress.completedUnitCount = self.downloadTask.countOfBytesReceived;
        for (void(^block)(FKSingleTask *) in self.progressBlocks) {
            block(self);
        }
    }
}

- (FKSingleTask *)status:(void(^)(FKSingleTask *task))status {
    [self.statusBlocks addObject:status];
    return self;
}

- (FKSingleTask *)progress:(void(^)(FKSingleTask *task))progress {
    [self.progressBlocks addObject:progress];
    return self;
}

- (FKSingleTask *)success:(void(^)(FKSingleTask *task))success {
    [self.successBlocks addObject:success];
    return self;
}

- (FKSingleTask *)faild:(void(^)(FKSingleTask *task))faild {
    [self.faildBlocks addObject:faild];
    return self;
}


#pragma mark - Override
- (NSUInteger)hash {
    return self.identifier.hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]] && [self.identifier isEqualToString:[object identifier]]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Getter/setter
- (void)setIdentifier:(NSString *)identifier {
    _identifier = identifier;
    
    NSString *taskDir = [self.manager.configure.rootPath stringByAppendingPathComponent:self.identifier];
    if ([self.manager.fileManager fileExistsAtPath:taskDir] == NO) {
        [self.manager.fileManager createDirectoryAtPath:taskDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSData *)resumeData {
    if (_resumeData) {
        return _resumeData;
    } else {
        NSString *dtrPath = [[self.identifier taskDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dtr", self.identifier]];
        if ([self.manager.fileManager fileExistsAtPath:dtrPath]) {
            return [NSData dataWithContentsOfFile:dtrPath options:NSDataReadingMappedIfSafe error:nil];
        } else {
            return nil;
        }
    }
}

- (NSProgress *)taskProgress {
    if (!_taskProgress) {
        _taskProgress = [NSProgress progressWithTotalUnitCount:1];
    }
    return _taskProgress;
}

- (NSMutableSet *)statusBlocks {
    if (!_statusBlocks) {
        _statusBlocks = [NSMutableSet set];
    }
    return _statusBlocks;
}

- (NSMutableSet *)progressBlocks {
    if (!_progressBlocks) {
        _progressBlocks = [NSMutableSet set];
    }
    return _progressBlocks;
}

- (NSMutableSet *)successBlocks {
    if (!_successBlocks) {
        _successBlocks = [NSMutableSet set];
    }
    return _successBlocks;
}

- (NSMutableSet *)faildBlocks {
    if (!_faildBlocks) {
        _faildBlocks = [NSMutableSet set];
    }
    return _faildBlocks;
}

@end
