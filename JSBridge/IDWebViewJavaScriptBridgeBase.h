//
//  IDWebViewJavaScriptBridgeBase.h
//  IDWebViewJavaScriptBridge
//
//  Created by ZLK on 2019/1/15.
//  Copyright © 2019年 ___ZLK___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kQueueHasMessage   @"nativeBridge"
#define kBridgeLoaded      @"bridgeLoaded"

typedef void(^BridgeResponseCallback)(id responseData);
typedef void(^BridgeHandler)(id data, BridgeResponseCallback responseCallback);
typedef NSDictionary BridgeMessage;

@protocol WebViewJavascriptBridgeBaseDelegate <NSObject>
- (void)_evaluateJavascript:(NSString*)javascriptCommand;
@end

@interface IDWebViewJavaScriptBridgeBase : NSObject
@property (weak, nonatomic) id <WebViewJavascriptBridgeBaseDelegate> delegate;
@property (strong, nonatomic) NSMutableArray* startupMessageQueue;
@property (strong, nonatomic) NSMutableDictionary* responseCallbacks;
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;


/**
 在使用的类里，重写该方法可设置开启日志打印
 */
+ (void)enableLogging;
/**
 在使用的类里，重写该方法可设置Log打印的最大长度
 */
+ (void)setLogMaxLength:(NSInteger)length;

- (void)reset;
- (void)sendData:(id)data responseCallBack:(BridgeResponseCallback)responseCallback handlerName:(NSString *)handlerName;

- (void)injectJavascriptFile;
- (NSString *)webViewJavascriptFetchQueyCommand;
- (void)disableJavscriptAlertBoxSafetyTimeout;

- (void)flushMessageQueue:(NSString *)messageQueueString;
@end
