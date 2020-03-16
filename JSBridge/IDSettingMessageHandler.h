//
//  IDSettingMessageHandler.h
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDBaseMessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IDSettingMessageHandlerProtocol <NSObject>

- (void)settingMessageHandler:(NSDictionary *)args;

@end

@interface IDSettingMessageHandler : IDBaseMessageHandler
@property (nonatomic,weak) id <IDSettingMessageHandlerProtocol> delegate;
@end

NS_ASSUME_NONNULL_END
