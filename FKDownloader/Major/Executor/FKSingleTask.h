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

typedef void(^FKStatusBlock)(id<FKTaskProtocol> task);
typedef void(^FKProgressBlock)(id<FKTaskProtocol> task);
typedef void(^FKSuccessBlock)(id<FKTaskProtocol> task);
typedef void(^FKFaildBlock)(id<FKTaskProtocol> task);

NS_ASSUME_NONNULL_BEGIN

@interface FKSingleTask : NSObject<FKTaskProtocol>

@property (nonatomic, weak  ) FKDownloadManager *manager;
@property (nonatomic, assign) uint64_t length;
@property (nonatomic, strong) NSString *tmp;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, strong) NSString *ext;

- (instancetype)initWithLink:(NSString *)link;
+ (instancetype)taskWithLink:(NSString *)link;

- (NSString *)link;

- (FKSingleTask *)status:(void(^)(FKSingleTask *task))status;
- (FKSingleTask *)progress:(void(^)(FKSingleTask *task))progress;
- (FKSingleTask *)success:(void(^)(FKSingleTask *task))success;
- (FKSingleTask *)faild:(void(^)(FKSingleTask *task))faild;

- (FKSingleTask *)start;
- (FKSingleTask *)suspend;
- (FKSingleTask *)resume;
- (FKSingleTask *)cancel;

@end

NS_ASSUME_NONNULL_END
