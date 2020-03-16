//
//  IDPlayerMessageHandler.h
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDBaseMessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IDPlayerMessageHandlerProtocol <NSObject>
- (void)playerPauseMessageHandler:(NSDictionary *)args;
- (void)playerPlayMessageHandler:(NSDictionary *)args;
@end

@interface IDPlayerMessageHandler : IDBaseMessageHandler

@property(nonatomic,weak) id <IDPlayerMessageHandlerProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
