//
//  AuthorizeLogoutViewController.m
//  MakeysSDKDemo
//
//  Created by dn4 on 2018/5/29.
//  Copyright © 2018年 zml. All rights reserved.
//

#import "AuthorizeLogoutViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"

@interface AuthorizeLogoutViewController ()
@property (nonatomic,strong) UIButton *logoutButton;
@property (nonatomic,strong) UILabel *infoLabel;

@end

@implementation AuthorizeLogoutViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.logoutButton];

    [self.view addSubview:self.infoLabel];
    
    CGFloat logoutButtonY = self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(logoutButtonY+50.0);
        make.left.and.right.equalTo(self.view);
        make.height.mas_offset(50);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoutButton.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(15.0);
        make.right.equalTo(self.view).offset(-15.0);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Methods
-(UIButton *)logoutButton{
    if (!_logoutButton) {
        _logoutButton  = [UIButton new];
        _logoutButton.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:150.0/255.0 blue:246.0/255.0 alpha:1.0];
        [_logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
        [_logoutButton addTarget:self action:@selector(clickLogout:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutButton;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.font = [UIFont systemFontOfSize:15];
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

#pragma mark - Setter
- (void)setResponseObject:(NSDictionary *)responseObject {
    
    _responseObject = responseObject;
    
    NSDictionary *data = responseObject[@"data"];
    if (data == nil) {
        return;
    }
    NSString *tipStr = @"登录成功";
    NSString *infoStr = [NSString stringWithFormat:@"%@\n用户信息：\n昵称 = %@\n帐号 = %@\n区号 = %@\n手机号 = %@\nuuid = %@\n ",tipStr,data[@"nickname"],data[@"name"],data[@"nationCode"],data[@"mobile"],data[@"uuid"]];
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:infoStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attriString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}
                         range:[infoStr rangeOfString:tipStr]];
    [attriString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, tipStr.length)];
    self.infoLabel.attributedText = attriString;
}

#pragma mark - Private Methods
- (void)clickLogout:(id)sender {
    NSString *path = @"logout";
    NSString *baseUrlStr = @"http://test-authclient.makeys.info";
    [self requestWithBaseURL:baseUrlStr path:path params:nil];
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
            [self gotoAuthorizeLoginViewController:responseObject];
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

- (void)gotoAuthorizeLoginViewController:(NSDictionary *)responseObject {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
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
