//
//  IDAppMessageHandler.h
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDBaseMessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IDAppMessageHandlerProtocol <NSObject>
- (void)appMessageHandler:(NSDictionary *)args;
@end

@interface IDAppMessageHandler : IDBaseMessageHandler

@property(nonatomic,weak) id <IDAppMessageHandlerProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
