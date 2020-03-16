//
//  IDUserMessageHandler.h
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDBaseMessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IDUserMessageHandlerProtocol <NSObject>
- (void)userMessageHandler:(NSDictionary *)args;
- (void)userLoginMessageHandler:(NSDictionary *)args;
@end

@interface IDUserMessageHandler : IDBaseMessageHandler

@property(nonatomic,weak) id <IDUserMessageHandlerProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
