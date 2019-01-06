//
//  FKTaskProtocol.h
//  FKDownloader
//
//  Created by norld on 2019/1/2.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKDefine.h"

/**
 核心: 任务即文件, 文件即任务, 文件不保存状态
 - dir(task.identifier)
 |- task.identifier.dti         // 任务信息
 |- task.identifier.{idx}.dtt   // 下载缓存, 可能为多个
 |- task.identifier.{idx}.dtr   // 恢复信息, 可能为多个
 |- task.identifier.dtf         // 完成文件, 可能为多个
 */

NS_ASSUME_NONNULL_BEGIN

@protocol FKTaskProtocol <NSObject>

@required
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) uint64_t length;
@property (nonatomic, assign) uint64_t number;
@property (nonatomic, assign) FKTaskType type;
@property (nonatomic, assign) FKTaskStatus status;

- (id<FKTaskProtocol>)start;
- (id<FKTaskProtocol>)suspend;
- (id<FKTaskProtocol>)resume;
- (id<FKTaskProtocol>)cancel;

- (id<FKTaskProtocol>)status:(void(^)(id<FKTaskProtocol> task))status;
- (id<FKTaskProtocol>)progress:(void(^)(id<FKTaskProtocol> task))progress;
- (id<FKTaskProtocol>)success:(void(^)(id<FKTaskProtocol> task))success;
- (id<FKTaskProtocol>)faild:(void(^)(id<FKTaskProtocol> task))faild;

@end

NS_ASSUME_NONNULL_END
