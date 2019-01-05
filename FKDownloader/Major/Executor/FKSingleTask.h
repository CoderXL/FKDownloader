//
//  FKSingleTask.h
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKTaskProtocol.h"
@class FKDownloadManager;

typedef void(^FKStatusBlock)(void);
typedef void(^FKProgressBlock)(void);
typedef void(^FKSuccessBlock)(void);
typedef void(^FKFaildBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface FKSingleTask : NSObject<FKTaskProtocol>

@property (nonatomic, weak  ) FKDownloadManager *manager;
@property (nonatomic, assign) uint64_t length;
@property (nonatomic, strong) NSString *tmp;
@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic, copy  ) FKStatusBlock status;
@property (nonatomic, copy  ) FKProgressBlock progress;
@property (nonatomic, copy  ) FKSuccessBlock success;
@property (nonatomic, copy  ) FKFaildBlock faild;

- (void)obWithSt:(FKStatusBlock)st
            prog:(FKProgressBlock)prog
         success:(FKSuccessBlock)success
           faild:(FKFaildBlock)faild;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
