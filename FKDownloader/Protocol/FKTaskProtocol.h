//
//  FKTaskProtocol.h
//  FKDownloader
//
//  Created by norld on 2019/1/2.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FKTaskProtocol <NSObject>

@required
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *link;
@property(nonatomic, assign) uint64_t number;
@property(nonatomic, assign) FKTaskType type;

- (void)start;
- (void)suspend;
- (void)resume;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
