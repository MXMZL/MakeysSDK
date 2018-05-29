//
//  MakeysSDK.h
//  MakeysSDK
//
//  Created by dn4 on 2018/5/25.
//  Copyright © 2018年 zml. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MakeysSDKDelegate;
@class MakeysBaseRequest;
@class MakeysBaseResponse;

typedef NS_ENUM(NSInteger, MakeysSDKResponseStatusCode)
{
    MakeysSDKResponseStatusCodeSuccess               = 0,//成功
    MakeysSDKResponseStatusCodeUserCancel             = -1,//用户取消
    MakeysSDKResponseStatusCodeAuthDeny              = -2,//授权失败
    MakeysSDKResponseStatusCodeUserCancelInstall     = -3,//用户取消安装Makeys客户端
};

typedef NS_ENUM(NSInteger, MakeysSDKLanguageType)
{
    MakeysSDKLanguageTypeChinese               = -1,//中文
    MakeysSDKLanguageTypeEnglish               = -2,//英文
};

@interface MakeysSDK : NSObject
/**
 检查用户是否安装了Makeys客户端程序
 @return 已安装返回YES，未安装返回NO
 */
+ (BOOL)isMakeysAppInstalled;

/**
 获取当前Makeys的版本号
 @return 当前MakeysSDK的版本号
 */
+ (NSString *)getSDKVersion;

/**
 设置语言
 @param languageType 设置语言，默认跟随系统，若系统语言为中文，则为简体中文，否则，为英文
 @return 语言设置成功返回YES，失败返回NO
 */
+ (BOOL)setLanguageType:(MakeysSDKLanguageType)languageType;

/**
 向Makeys客户端程序注册第三方应用
 @param appKey Makeys开放平台第三方应用appKey
 @return 注册成功返回YES，失败返回NO
 */
+ (BOOL)registerApp:(NSString *)appKey;

/**
 处理Makeys客户端程序通过URL启动第三方应用时传递的数据
 
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 @param url 启动第三方应用的URL
 @param delegate MakeysSDKDelegate对象，用于接收Makeys触发的消息
 @see MakeysSDKDelegate
 */
+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id<MakeysSDKDelegate>)delegate;

/**
 发送请求给Makeys客户端程序，并切换到Makeys
 
 请求发送给Makeys客户端程序之后，Makeys客户端程序会进行相关的处理，处理完成之后一定会调用 [MakeysSDKDelegate didReceiveMakeysResponse:responseStatusCode:] 方法将处理结果返回给第三方应用
 
 @param request 具体的发送请求
 
 @see [MakeysSDKDelegate didReceiveWeiboResponse:responseStatusCode:]
 @see WBBaseResponse
 */
+ (BOOL)sendRequest:(MakeysBaseRequest *)request;

@end

/**
 接收并处理来至Makeys客户端程序的事件消息
 */
@protocol MakeysSDKDelegate <NSObject>

/**
 收到一个来自Makeys客户端程序的响应
 
 收到Makeys的响应后，第三方应用可以通过响应类型、响应的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveMakeysResponse:(MakeysBaseResponse *)response responseStatusCode:(MakeysSDKResponseStatusCode)responseStatusCode;

@end

#pragma mark - Base Request/Response
/**
 Makeys客户端程序和第三方应用之间传输数据信息的基类
 */
@interface MakeysBaseRequest : NSObject
/**
 当用户没有安装Makeys客户端程序时是否提示用户打开Makeys安装页面
 
 如果设置为YES，当用户未安装Makeys时会弹出Alert询问用户是否要打开Makeys App的安装页面。默认为YES
 */
@property (nonatomic, assign) BOOL shouldOpenMakeysAppInstallPageIfNotInstalled;

/**
 自定义信息字符串，用于数据传输过程中校验相关的上下文环境数据
 
 如果未填写，则response.requestState为空；若填写，响应成功时，则 response.requestState 和原 request.state 中的数据保持一致
 */
@property (nonatomic, strong) NSString *state;

/**
 返回一个 MakeysBaseRequest 对象
 
 @return 返回一个*自动释放的*MakeysBaseRequest对象
 */
+ (id)request;

@end

/**
 MakeysSDK所有响应类的基类
 */
@interface MakeysBaseResponse : NSObject
/**
 返回一个 MakeysBaseResponse 对象
 
 @return 返回一个*自动释放的*MakeysBaseResponse对象
 */
+ (id)response;

@end

#pragma mark - Authorize Request/Response
/**
 第三方应用向Makeys客户端请求认证的消息结构
 
 第三方应用向Makeys客户端申请认证时，需要调用 [MakeysSDK sendRequest:] 函数， 向Makeys客户端发送一个 MakeysAuthorizeRequest 的消息结构。
 Makeys客户端处理完后会向第三方应用发送一个结构为 MakeysBaseResponse 的处理结果。
 */
@interface MakeysAuthorizeRequest : MakeysBaseRequest

/**
 Makeys开放平台第三方应用授权回调页地址，默认为`http://`
 
 参考
 
 @warning 必须保证和在Makeys开放平台应用管理界面配置的“授权回调页”地址一致，如未进行配置则默认为`http://`
 @warning 不能为空，长度小于1K
 */
@property (nonatomic, strong) NSString *redirectURI;

/**
 Makeys开放平台第三方应用scope，多个scrope用逗号分隔
 
 参考
 
 @warning 长度小于1K
 */
@property (nonatomic, strong) NSString *scope;

@end

/**
 MakeysSDK处理完第三方应用的认证申请后向第三方应用回送的处理结果
 
 MakeysSuccessedResponse 结构中包含常用的 requestState、accessToken
 */
@interface MakeysSuccessedResponse : MakeysBaseResponse

/**
 对应的 request 中的state
 
 如果当前 response 是由MakeysSDK响应给第三方应用的，则 requestState 和原 request.state 中的数据保持一致
 
 @see MakeysBaseRequest.state
 */
@property (nonatomic, strong) NSString *requestState;

/**
 认证口令
 */
@property (nonatomic, strong) NSString *accessToken;

@end

@interface MakeysFailedResponse : MakeysBaseResponse
/**
 响应状态码
 
 第三方应用可以通过errorCode判断请求的处理结果
 */
@property (nonatomic, strong) NSString *errorCode;

/**
 响应状态码描述
 
 第三方应用可以通过errorCodeDescription判断请求的显示结果
 */
@property (nonatomic, strong) NSString *errorCodeDescription;

@end
