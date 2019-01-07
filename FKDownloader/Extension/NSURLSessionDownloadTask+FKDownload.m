//
//  NSURLSessionDownloadTask+FKDownload.m
//  FKDownloaderDemo
//
//  Created by norld on 2019/1/5.
//  Copyright © 2019 Norld. All rights reserved.
//

#import "NSURLSessionDownloadTask+FKDownload.h"
#import <objc/runtime.h>

@implementation NSURLSessionDownloadTask (FKDownload)

- (NSString *)fkidentifier {
    return objc_getAssociatedObject(self, @selector(fkidentifier));
}

- (void)setFkidentifier:(NSString *)fkidentifier {
    objc_setAssociatedObject(self, @selector(fkidentifier), fkidentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)idx {
    return [objc_getAssociatedObject(self, @selector(idx)) integerValue];
}

- (void)setIdx:(NSInteger)idx {
    objc_setAssociatedObject(self, @selector(idx), @(idx), OBJC_ASSOCIATION_ASSIGN);
}

@end
