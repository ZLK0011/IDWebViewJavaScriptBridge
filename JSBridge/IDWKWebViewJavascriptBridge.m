//
//  IDWKWebViewJavascriptBridge.m
//  IDWebViewJavaScriptBridge
//
//  Created by ZLK on 2019/1/15.
//  Copyright © 2019年 ___ZLK___. All rights reserved.
//

#import "IDWKWebViewJavascriptBridge.h"

@implementation IDWKWebViewJavascriptBridge {
    __weak WKWebView *_webView;
    __weak id<WKNavigationDelegate> _webViewDelegate;
    long _uniqueId;
    IDWebViewJavaScriptBridgeBase *_base;
}

+ (void)enableLogging {
    [IDWebViewJavaScriptBridgeBase enableLogging];
}

//初始化 Bridge
+ (instancetype)bridgeForWebView:(WKWebView *)webView {
    IDWKWebViewJavascriptBridge *bridge = [[self alloc] init];
    [bridge _setupInstance:webView];
    [bridge reset];
    return bridge;
}

- (void)_setupInstance:(WKWebView*)webView {
    _webView = webView;
    WKUserContentController *userContentController = _webView.configuration.userContentController;
    [userContentController addScriptMessageHandler:self name:kQueueHasMessage];
    [userContentController addScriptMessageHandler:self name:kBridgeLoaded];
    _webView.configuration.userContentController = userContentController;
    
    _base = [[IDWebViewJavaScriptBridgeBase alloc] init];
    _base.delegate = self;//base类的发送message JsonString的代理
}

- (void)reset {
    [_base reset];
}

- (void)registerHander:(NSString *)handlerName handler:(BridgeHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}

- (void)removeHandler:(NSString *)handlerName {
    [_base.messageHandlers removeObjectForKey:handlerName];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(BridgeResponseCallback)responseCallback {
    [_base sendData:data responseCallBack:responseCallback handlerName:handlerName];
}

- (void)WKFlushMessageQueue {
    [_webView evaluateJavaScript:[_base webViewJavascriptFetchQueyCommand] completionHandler:^(NSString* result, NSError* error) {
        if (error != nil) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        //拉取前端消息并处理
        [self->_base flushMessageQueue:result];
    }];
}

- (void)_evaluateJavascript:(NSString *)javascriptCommand {
    [_webView evaluateJavaScript:javascriptCommand completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"evaluateJavaScript ERROR：%@",[error description]);
    }];
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [_base disableJavscriptAlertBoxSafetyTimeout];
}

#pragma mark --WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"前端传递的handleName %@: ",message.name);
    if (userContentController != _webView.configuration.userContentController) {
        return;
    }
    
    if ([message.name isEqualToString:kBridgeLoaded]) {
        [_base injectJavascriptFile];
    }else if ([message.name isEqualToString:kQueueHasMessage]) {
        [self WKFlushMessageQueue];
    }else {
        NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command");
    }

}

@end
