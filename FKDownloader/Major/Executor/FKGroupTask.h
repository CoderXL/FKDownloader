//
//  FKGroupTask.h
//  FKDownloader
//
//  Created by norld on 2019/1/4.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FKTaskProtocol.h>
@class FKDownloadManager;

NS_ASSUME_NONNULL_BEGIN

@interface FKGroupTask : NSObject<FKTaskProtocol>

@property (nonatomic, weak  ) FKDownloadManager *manager;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
