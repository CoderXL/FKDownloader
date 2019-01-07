//
//  NSURLSessionDownloadTask+FKDownload.h
//  FKDownloaderDemo
//
//  Created by norld on 2019/1/5.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionDownloadTask (FKDownload)

@property (nonatomic, strong) NSString *fkidentifier;   // 任务标识
@property (nonatomic, assign) NSInteger idx;    // 标记 group/drip 子任务编号

@end

NS_ASSUME_NONNULL_END
