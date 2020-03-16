//
//  IDHandlerManager.m
//  IDWebViewJavaScriptBridge
//
//  Created by 王祥 on 2020/3/13.
//  Copyright © 2020 idaddy. All rights reserved.
//

#import "IDHandlerManager.h"
#import "IDUserMessageHandler.h"
#import "IDAppMessageHandler.h"
#import "IDPlayerMessageHandler.h"
#import "IDPageMessageHandler.h"
#import "IDSettingMessageHandler.h"

@interface IDHandlerManager ()
@property (nonatomic,strong) IDUserMessageHandler *userMessageHandler;
@property (nonatomic,strong) IDAppMessageHandler *appMessageHandler;
@property (nonatomic,strong) IDPlayerMessageHandler *playerMessageHandler;
@property (nonatomic,strong) IDSettingMessageHandler *settingMessageHandler;
@property (nonatomic,strong) IDPageMessageHandler *pageMessageHandler;
@end

@implementation IDHandlerManager

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static IDHandlerManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[IDHandlerManager alloc] init];
    });
    
    return instance;
}

- (void)registerAllHandlersForJSBridge:(IDWKWebViewJavascriptBridge *)bridge delegate:(nonnull id)executor{
    [IDWKWebViewJavascriptBridge enableLogging];
    // 注册 handler
    _userMessageHandler = [[IDUserMessageHandler alloc] init];
    _userMessageHandler.delegate = executor;
    _userMessageHandler.bridge = bridge;
    [_userMessageHandler registerHandlersForJSBridge:bridge];
    
    _appMessageHandler = [[IDAppMessageHandler alloc] init];
    _appMessageHandler.delegate = executor;
    _appMessageHandler.bridge = bridge;
    [_appMessageHandler registerHandlersForJSBridge:bridge];
    
    _playerMessageHandler = [[IDPlayerMessageHandler alloc] init];
    _playerMessageHandler.delegate = executor;
    _playerMessageHandler.bridge = bridge;
    [_playerMessageHandler registerHandlersForJSBridge:bridge];
    
    _settingMessageHandler = [[IDSettingMessageHandler alloc] init];
    _settingMessageHandler.delegate = executor;
    _settingMessageHandler.bridge = bridge;
    [_settingMessageHandler registerHandlersForJSBridge:bridge];
    
    _pageMessageHandler = [[IDPageMessageHandler alloc] init];
    _pageMessageHandler.delegate = executor;
    _pageMessageHandler.bridge = bridge;
    [_pageMessageHandler registerHandlersForJSBridge:bridge];
}

@end
