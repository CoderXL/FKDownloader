//
//  FKSingleTask.h
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FKTaskProtocol.h>
@class FKDownloadManager;

NS_ASSUME_NONNULL_BEGIN

@interface FKSingleTask : NSObject<FKTaskProtocol>

@property (nonatomic, weak  ) FKDownloadManager *manager;
@property (nonatomic, assign) uint64_t length;
@property (nonatomic, strong) NSString *tmp;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
