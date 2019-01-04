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

typedef void(^finish)(long length, int idx);
void pollingLength(NSArray *linkes, finish f) {
    for (int i = 0; i < linkes.count; i++) {
        NSString *link = [linkes objectAtIndex:i];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
        request.HTTPMethod = @"HEAD";
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSNumber *length = @(0);
            if ([response respondsToSelector:@selector(allHeaderFields)]) {
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                NSDictionary *header = res.allHeaderFields;
                NSNumber *temp = [[NSNumberFormatter new] numberFromString:[header valueForKey:@"Content-Length"]];
                if (temp) { length = temp; }
            }
            if (f) {
                f(length.longValue, i);
            }
        }] resume];
    }
}

@interface FKSingleTask ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation FKSingleTask
@synthesize link = _link;
@synthesize identifier = _identifier;
@synthesize number = _number;
@synthesize type = _type;

- (void)start {
    
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
