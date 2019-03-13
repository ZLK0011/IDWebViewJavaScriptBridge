//
//  IDWKWebViewJavascriptBridge.h
//  IDWebViewJavaScriptBridge
//
//  Created by ZLK on 2019/1/15.
//  Copyright © 2019年 ___ZLK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDWebViewJavaScriptBridgeBase.h"
#import <WebKit/WebKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface IDWKWebViewJavascriptBridge : NSObject<WebViewJavascriptBridgeBaseDelegate, WKScriptMessageHandler>
+ (void)enableLogging;
+ (instancetype)bridgeForWebView:(WKWebView *)webView;

- (void)registerHander:(NSString *)handlerName handler:(BridgeHandler)handler;

- (void)reset;
- (void)removeHandler:(NSString *)handlerName;
- (void)callHandler:(NSString *)handlerName;
- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(BridgeResponseCallback)responseCallback;

- (void)disableJavscriptAlertBoxSafetyTimeout;
@end

//NS_ASSUME_NONNULL_END
