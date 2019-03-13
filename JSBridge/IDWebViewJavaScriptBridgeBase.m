//
//  IDWebViewJavaScriptBridgeBase.m
//  IDWebViewJavaScriptBridge
//
//  Created by ZLK on 2019/1/15.
//  Copyright © 2019年 ___ZLK___. All rights reserved.
//

#import "IDWebViewJavaScriptBridgeBase.h"
#import "WebViewJavascriptBridge_JS.h"

@implementation IDWebViewJavaScriptBridgeBase {
    
    long _uniqueId;
}

static BOOL logging = NO;
static NSInteger logMaxLength = 500;

+ (void)enableLogging {
    logging = YES;
}

+ (void)setLogMaxLength:(NSInteger)maxLength {
    logMaxLength = maxLength;
}

- (instancetype)init {
    if (self = [super init]) {
        self.messageHandlers = [NSMutableDictionary dictionary];
        self.startupMessageQueue = [NSMutableArray array];
        self.responseCallbacks = [NSMutableDictionary dictionary];
        _uniqueId = 0;
    }
    return self;
}

- (void)dealloc {
    self.startupMessageQueue = nil;
    self.responseCallbacks = nil;
    self.messageHandlers = nil;
}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

/// 处理 JavaScript 消息队列中的消息，发送给 Objective-C 方
- (void)flushMessageQueue:(NSString *)messageQueueString {
    if (messageQueueString == nil || messageQueueString.length == 0) {
        NSLog(@"WebViewJavascriptBridge: WARNING: 移动端从JavaScript消息队列中获取d的消息为空，一般发生在JS的webviewJSbridge还没注入完成的时候，比如，页面刚刚加载完");
        return;
    }
    
    // 解析消息队列中的消息
    id messages = [self _deserializeMessageJSON:messageQueueString];
    
    for (BridgeMessage* message in messages) {
        if (![message isKindOfClass:[BridgeMessage class]]) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self _log:@"RCVD" json:message];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {   // JS 回调原生的处理
            BridgeResponseCallback responseCallback = _responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [self.responseCallbacks removeObjectForKey:responseId];
            
        } else {
             // 原生 回调JS的处理
            // 1. JavaScript 中 callback 的转换
            BridgeResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];  // 取出 JavaScript 中传过来的 callbackId
            
            if (callbackId) {  // 有 JavaScript 回调，将 callback 转换为 block
                responseCallback = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    
                    BridgeMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    // 回调 JavaScript
                    [self _queueMessage:msg];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            // 2. 根据 handlerName 取出对应的 handler
            BridgeHandler handler = self.messageHandlers[message[@"handlerName"]];
            
            if (!handler) {
                NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
                continue;
            }
            
            // 3. 执行 handler
            handler(message[@"data"], responseCallback);
        }
    }
}

/// 注入 JS ，进行一些初始化操作
- (void)injectJavascriptFile {
    NSString *js = WebViewJavascriptBridge_js();
    [self _evaluateJavascript:js];  // 执行 WebViewJavascriptBridge_JS 文件中的 JavaScript
    
    if (self.startupMessageQueue) {
        NSArray *queue = self.startupMessageQueue;
        self.startupMessageQueue = nil;
        for (id queuedMessage in queue) {
            [self _dispatchMessage:queuedMessage];
        }
    }
}

// 从消息队列中拉取消息
- (NSString *)webViewJavascriptFetchQueyCommand {
    return @"WebViewJavascriptBridge._fetchQueue();";
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [self sendData:nil responseCallBack:nil handlerName:@"_disableJavascriptAlertBoxSafetyTimeout"];
}

#pragma mark --发送BridgeMessage
- (void)sendData:(id)data responseCallBack:(BridgeResponseCallback)responseCallback handlerName:(NSString *)handlerName {
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    
    BridgeMessage *sendMessage = [message copy];
    [self _queueMessage:sendMessage];
}

- (void)_queueMessage:(BridgeMessage *)message {
    
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    }else {
        [self _dispatchMessage:message];
    }
}

#pragma mark --Public 处理BridgeMessage
- (void)_dispatchMessage:(BridgeMessage *)message {
    NSString *messageJSON = [self _serializeMessage:message pretty:NO];// 将消息转成JSONString发送
    [self _log:@"SEND" json:messageJSON];
    /*
     需对特殊字符转义处理否则JS解析不了，Javascript中的特殊字符需转义处理否则JS处理不了
     */
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

- (void) _evaluateJavascript:(NSString *)javascriptCommand {
    [self.delegate _evaluateJavascript:javascriptCommand];
}

//序列化 oc对象转json NSJSONWritingPrettyPrinted->格式化输出
- (NSString *)_serializeMessage:(id)message pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}
//反序列化 json对象转oc对象
- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

//在(flushMessageQueue里)处理JavaScript消息队列中的消息时Log传的BridgeMessage类型(NSDictionary)，所以传入的是id类型
- (void)_log:(NSString *)action json:(id)json {
    if (!logging) {
        return;
    }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        NSLog(@"WVJB %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        NSLog(@"WVJB %@: %@", action, json);
    }
}
@end
