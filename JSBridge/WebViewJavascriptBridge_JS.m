
#import "WebViewJavascriptBridge_JS.h"

NSString * WebViewJavascriptBridge_js() {
	#define __wvjb_js_func__(x) #x
	
	// BEGIN preprocessorJSCode
	static NSString * preprocessorJSCode = @__wvjb_js_func__(
;(function() {
       
	if (window.WebViewJavascriptBridge) {
		return;
	}
        
	if (!window.onerror) {
		window.onerror = function(msg, url, line) {
			console.log("WebViewJavascriptBridge: ERROR:" + msg + "@" + url + ":" + line);
		}
	}
	window.WebViewJavascriptBridge = {
		registerHandler: registerHandler,
		callHandler: callHandler,
		disableJavscriptAlertBoxSafetyTimeout: disableJavscriptAlertBoxSafetyTimeout,
		_fetchQueue: _fetchQueue,
		_handleMessageFromObjC: _handleMessageFromObjC
	};

	var sendMessageQueue = [];
	var messageHandlers = {};
		
	var responseCallbacks = {};
	var uniqueId = 1;
	var dispatchMessagesWithTimeoutSafety = true;

    // 注册handler的方法
	function registerHandler(handlerName, handler) {
		messageHandlers[handlerName] = handler;
	}
	// 调用 Native handler 的方法
	function callHandler(handlerName, data, responseCallback) {
        // 如果只有两个参数，并且第二个参数是 函数
		if (arguments.length == 2 && typeof data == 'function') {
			responseCallback = data;
			data = null;
		}
        // 发送消息给 Native
		_doSend({ handlerName:handlerName, data:data }, responseCallback);
	}
        
	function disableJavscriptAlertBoxSafetyTimeout() {
		dispatchMessagesWithTimeoutSafety = false;
	}
	
    // 发送消息给 Native
    // 一个消息包含一个 handler 和 data，以及一个 callbackId
    // 因为 JavaScript 中的 callback 是函数，不能直接传给 Objective-C
    //传responseCallback参数的情况主要是callHandler函数调用，即JS主动调Native
	function _doSend(message, responseCallback) {
		if (responseCallback) {
			var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
			responseCallbacks[callbackId] = responseCallback;
			message['callbackId'] = callbackId;
		}
		sendMessageQueue.push(message);
        //发送消息给Native,让Native通过_fetchQueue方法主动来拉取并处理消息
        window.webkit.messageHandlers.nativeBridge.postMessage(null);
	}

	function _fetchQueue() {
		var messageQueueString = JSON.stringify(sendMessageQueue);
		sendMessageQueue = [];
		return messageQueueString;
	}

    // 处理 Objective-C 中发来的消息
	function _dispatchMessageFromObjC(messageJSON) {
		if (dispatchMessagesWithTimeoutSafety) {
			setTimeout(_doDispatchMessageFromObjC);
		} else {
			 _doDispatchMessageFromObjC();
		}
		
		function _doDispatchMessageFromObjC() {
			var message = JSON.parse(messageJSON);//JSON解析
			var messageHandler;
			var responseCallback;
            //执行JavaScript调用原生时的回调
			if (message.responseId) {
				responseCallback = responseCallbacks[message.responseId];
				if (!responseCallback) {
					return;
				}
				responseCallback(message.responseData);
				delete responseCallbacks[message.responseId];
			} else {
            //原生调用JavaScript，并回调Native的callback
				if (message.callbackId) {
					var callbackResponseId = message.callbackId;
                    //创建responseCallback，以供调取完本地handler后回调给客户端
					responseCallback = function(responseData) {
                        //注意：此处只传了第一个参数，并且在原生调用JS的q这种情况下callbackId改为responseId（_doSend函数有两个参数：message和responseCallback）
						_doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
					};
				}
				
				var handler = messageHandlers[message.handlerName];
				if (!handler) {
					console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
				} else {
					handler(message.data, responseCallback);
				}
			}
		}
	}
	
	function _handleMessageFromObjC(messageJSON) {
        _dispatchMessageFromObjC(messageJSON);
	}
    //发送消息给Native
	window.webkit.messageHandlers.nativeBridge.postMessage(null);

	registerHandler("_disableJavascriptAlertBoxSafetyTimeout", disableJavscriptAlertBoxSafetyTimeout);
	
	setTimeout(_callWKJBCallbacks, 0);
	function _callWKJBCallbacks() {
		var callbacks = window.WKJBCallbacks;
		delete window.WKJBCallbacks;
		for (var i=0; i<callbacks.length; i++) {
			callbacks[i](WebViewJavascriptBridge);
		}
	}
})();
	); // END preprocessorJSCode

	#undef __wvjb_js_func__
	return preprocessorJSCode;
};
