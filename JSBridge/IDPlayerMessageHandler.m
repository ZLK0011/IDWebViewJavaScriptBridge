//
//  IDPlayerMessageHandler.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDPlayerMessageHandler.h"

@implementation IDPlayerMessageHandler
- (NSArray *)specialHandlerNames{
    return @[
            @"player.play",
            @"player.pause"
            ];
}

- (void)player_play:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(playerPlayMessageHandler:)]) {
        [self.delegate playerPlayMessageHandler:args];
    }
}

- (void)player_pause:(NSDictionary *)args {
    if ([self.delegate respondsToSelector:@selector(playerPauseMessageHandler:)]) {
        [self.delegate playerPauseMessageHandler:args];
    }
}
@end
