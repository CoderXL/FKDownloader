//
//  FKStorageHelper.h
//  FKDownloader
//
//  Created by norld on 2019/1/3.
//  Copyright © 2019 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FKTaskProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKStorageHelper : NSObject

+ (void)saveTask:(id<FKTaskProtocol>)task;
+ (id<FKTaskProtocol>)loadTaskWithIdentifier:(NSString *)identifier;

//+ (void)saveResumeDataWithTask:(id<FKTaskProtocol>)task;
//+ (void)loadResumeDataWithTask:(id<FKTaskProtocol>)task;

@end

NS_ASSUME_NONNULL_END
