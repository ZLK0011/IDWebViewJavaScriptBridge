//
//  IDSettingMessageHandler.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDSettingMessageHandler.h"

@implementation IDSettingMessageHandler

- (NSArray *)specialHandlerNames{
    return @[@"setting"];
}

- (void)setting:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(settingMessageHandler:)]) {
        [self.delegate settingMessageHandler:args];
    }
}

@end
