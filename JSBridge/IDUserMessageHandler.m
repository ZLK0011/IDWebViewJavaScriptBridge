//
//  IDUserMessageHandler.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDUserMessageHandler.h"

@implementation IDUserMessageHandler

- (NSArray *)specialHandlerNames{
    return @[
            @"user",
            @"user.login"
            ];
}

- (void)user:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(userMessageHandler:)]) {
        [self.delegate userMessageHandler:args];
    }
}

- (void)user_login:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(userLoginMessageHandler:)]) {
        [self.delegate userLoginMessageHandler:args];
    }
}

@end
