//
//  IDBaseMessageHandler.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/12.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDBaseMessageHandler.h"

@implementation IDBaseMessageHandler

- (void)registerHandlersForJSBridge:(IDWKWebViewJavascriptBridge *)bridge {
    
    NSMutableArray *handlerNames = [NSMutableArray array];//可以在初始化时一些方法
    
    [handlerNames addObjectsFromArray:[self specialHandlerNames]];
    
    for (NSString *aHandlerName in handlerNames) {
        [bridge registerHander:aHandlerName handler:^(id data, BridgeResponseCallback responseCallback) {
            NSMutableDictionary *args = [NSMutableDictionary dictionary];
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                [args addEntriesFromDictionary:data];
            }else {
                [args addEntriesFromDictionary:@{@"data":data}];
            }
            
            if (responseCallback) {
                [args setObject:responseCallback forKey:kReponseCallbackKey];
            }
            if (aHandlerName) {
                [args setObject:aHandlerName forKey:@"handlerName"];
            }
            
            NSString *ObjCMethodName = [aHandlerName stringByAppendingString:@":"];
            ObjCMethodName = [ObjCMethodName stringByReplacingOccurrencesOfString:@"." withString:@"_"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:NSSelectorFromString(ObjCMethodName) withObject:args];
#pragma clang diagnostic pop
            
        }];
    }
}

- (NSArray *)specialHandlerNames {
    return @[];
}


@end
