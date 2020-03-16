//
//  IDPageMessageHandler.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDPageMessageHandler.h"

@implementation IDPageMessageHandler
- (NSArray *)specialHandlerNames{
    return @[@"page"];
}

- (void)page:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(pageMessageHandler:)]) {
        [self.delegate pageMessageHandler:args];
    }
}
@end
