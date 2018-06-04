//
//  AuthorizeLoginViewController.m
//  MakeysSDKDemo
//
//  Created by dn4 on 2018/5/28.
//  Copyright © 2018年 zml. All rights reserved.
//

#import "AuthorizeLoginViewController.h"
#import "AuthorizeLogoutViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"

@interface AuthorizeLoginViewController ()
@property (nonatomic,strong) UIButton *loginButton;
@end

@implementation AuthorizeLoginViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"MakeysSDKDemo";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.loginButton];
    CGFloat loginButtonY = self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(loginButtonY+50);
        make.left.and.right.equalTo(self.view);
        make.height.mas_offset(50);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Methods
-(UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton  = [UIButton new];
        _loginButton.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:150.0/255.0 blue:246.0/255.0 alpha:1.0];
        [_loginButton setTitle:@"Makeys授权登录" forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(clickLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

#pragma mark - Public Methods
- (void)loginByAuthCode:(NSDictionary *)params {
    
    NSString *path = @"loginByAuthCode";
    NSString *baseUrlStr = @"http://test-authclient.makeys.info";
    [self requestWithBaseURL:baseUrlStr path:path params:params];
}

#pragma mark - Private Methods
- (void)clickLogin:(id)sender {
    
    MakeysAuthorizeRequest *request = [MakeysAuthorizeRequest request];
    request.scope = @"user_info";
    request.state = @"Verification";
    request.redirectURI = kRedirectURI;
    [MakeysSDK sendRequest:request];
}

- (void)requestWithBaseURL:(NSString *)baseUrlStr
                      path:(NSString *)path
                    params:(NSDictionary *)params
{
    NSURL *baseUrl = [NSURL URLWithString:baseUrlStr];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
    
    [manager POST:path parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 20000) {
            [self gotoAuthorizeLogoutViewController:responseObject];
        }
        else {
            NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"desc"]];
            [self showFailResponseAlert:message];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *message = [NSString stringWithFormat:@"%@",error];
        [self showFailResponseAlert:message];
    }];
}

- (void)gotoAuthorizeLogoutViewController:(NSDictionary *)responseObject {
    
    AuthorizeLogoutViewController *vc = [[AuthorizeLogoutViewController alloc] init];
    vc.responseObject = responseObject;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFailResponseAlert:(NSString *)error {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求失败" message:error preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
