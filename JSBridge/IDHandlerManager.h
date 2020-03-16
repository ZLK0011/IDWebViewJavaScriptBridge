//
//  IDHandlerManager.h
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDWKWebViewJavascriptBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface IDHandlerManager : NSObject

+ (instancetype)sharedManager;

- (void)registerAllHandlersForJSBridge:(IDWKWebViewJavascriptBridge *)bridge delegate:(id)executor;

@end

NS_ASSUME_NONNULL_END
