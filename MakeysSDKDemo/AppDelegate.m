//
//  AppDelegate.m
//  MakeysSDKDemo
//
//  Created by dn4 on 2018/5/28.
//  Copyright © 2018年 zml. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthorizeLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MakeysSDK registerApp:kAppKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    AuthorizeLoginViewController *vc = [[AuthorizeLoginViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark -
- (void)didReceiveMakeysResponse:(MakeysBaseResponse *)response responseStatusCode:(MakeysSDKResponseStatusCode)responseStatusCode {
    
    if (responseStatusCode == MakeysSDKResponseStatusCodeSuccess) {
        MakeysSuccessedResponse *authorizeResponse = (MakeysSuccessedResponse *)response;
        NSString *requestState = authorizeResponse.requestState;
        NSString *accessToken = authorizeResponse.accessToken;
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        int num = (arc4random() % 10000000000);
        NSString *randomNumber = [NSString stringWithFormat:@"%.10d", num];
        parameters[@"state"] = requestState;
        parameters[@"redirectUri"] = kRedirectURI;
        parameters[@"code"] = accessToken;
        parameters[@"nonce"] = randomNumber;
        UINavigationController *rootNav = (UINavigationController *)self.window.rootViewController;
        AuthorizeLoginViewController *rootVC = rootNav.viewControllers.firstObject;
        [rootVC loginByAuthCode:parameters];
    }
    else if (responseStatusCode == MakeysSDKResponseStatusCodeAuthDeny) {
        MakeysFailedResponse *authorizeResponse = (MakeysFailedResponse *)response;
        NSString *errorCode = authorizeResponse.errorCode;
        NSString *errorCodeDescription = authorizeResponse.errorCodeDescription;
        NSString *message = [NSString stringWithFormat:@"response.errorCode:%@\nresponse.errorCodeDescription:%@",errorCode,errorCodeDescription];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"授权失败" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:actionCancel];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    else if (responseStatusCode == MakeysSDKResponseStatusCodeUserCancel) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"用户点击取消" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:actionCancel];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    else if (responseStatusCode == MakeysSDKResponseStatusCodeUserCancelInstall) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"用户取消下载" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:actionCancel];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [MakeysSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [MakeysSDK handleOpenURL:url delegate:self ];
}
@end
