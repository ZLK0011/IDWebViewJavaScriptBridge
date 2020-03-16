//
//  IDBaseMessageHandler.h
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/12.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDWKWebViewJavascriptBridge.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kReponseCallbackKey = @"responseCallback";
@interface IDBaseMessageHandler : NSObject

@property (weak, nonatomic) IDWKWebViewJavascriptBridge *bridge;

/// 注册 handler
- (void)registerHandlersForJSBridge:(IDWKWebViewJavascriptBridge *)bridge;

/// 要注册的特定 handler name，子类重写
- (NSArray *)specialHandlerNames;

@end

NS_ASSUME_NONNULL_END
