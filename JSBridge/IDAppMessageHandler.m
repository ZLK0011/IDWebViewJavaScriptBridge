//
//  IDAppMessageHandler.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDAppMessageHandler.h"

@implementation IDAppMessageHandler

- (NSArray *)specialHandlerNames{
    return @[
            @"app"
            ];
}

- (void)app:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(appMessageHandler:)]) {
        [self.delegate appMessageHandler:args];
    }
}

@end
