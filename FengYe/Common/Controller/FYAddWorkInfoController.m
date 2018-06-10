//
//  FYAddWorkInfoController.m
//  FengYe
//
//  Created by Alan Turing on 2018/5/26.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYAddWorkInfoController.h"
#import "CommonAttr.h"
#import "UIView+Frame.h"
#import "UITextView+Placeholder.h"
#import <UIImageView+WebCache.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>

@interface FYAddWorkInfoController ()
@property(nonatomic, retain) UITextView* gDescriptionTV;

@end

@implementation FYAddWorkInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = MainBackgroundColor;

    //顶部视图
    UIView* topView = [self setupTopView];
    
    //中间显示图片的视图背景
    UIView* smallPictureBack = [self setupSmallPictureView:topView.frame.size.height];
    
    //文本描述信息
    self.gDescriptionTV = [self setupDescriptionView:smallPictureBack];
    
    
}

- (UITextView*) setupDescriptionView:(UIView*) prevView{
    
    CGFloat descriptionTFOffsetY = prevView.frame.origin.y + prevView.frame.size.height;
    
    UITextView* descriptionTV = [[UITextView alloc] initWithFrame:CGRectMake(0, descriptionTFOffsetY , ScreenWidth, prevView.frame.size.height*2/3)];
    descriptionTV.backgroundColor = [UIColor whiteColor];
    [descriptionTV setPlaceholder:@"作品描述" placeholdColor:[UIColor grayColor]];
    descriptionTV.text = self.unitData.descriptionText;
    descriptionTV.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:descriptionTV];
    
    return descriptionTV;
}

- (UIView*) setupSmallPictureView:(CGFloat) offset{
    
    //显示图片背后的一大整块区域背景
    UIView* smallPictureBack = [[UIView alloc] initWithFrame:CGRectMake(0, offset, ScreenWidth, ScreenHeight/4)];
    smallPictureBack.backgroundColor = MainBackgroundColor;
    [self.view addSubview:smallPictureBack];
    
    //显示图片的背景。用于限制图片的区域大小
    UIView* imageViewBack = [[UIView alloc] init];
    imageViewBack.fy_width = ScreenHeight / 4 / 5 * 3;
    imageViewBack.fy_height = ScreenHeight / 4 / 5 * 3;
    imageViewBack.fy_centerX = smallPictureBack.fy_centerX;
    imageViewBack.fy_centerY = smallPictureBack.frame.size.height / 2;
    imageViewBack.backgroundColor = [UIColor lightGrayColor];
    imageViewBack.clipsToBounds = YES;
    [smallPictureBack addSubview:imageViewBack];
    
    //图片
    UIImageView* imageView = [[UIImageView alloc] init];
    if (self.unitData.picHeight > self.unitData.picWidth) {
        
        CGFloat imageHeight = imageViewBack.frame.size.width * self.unitData.picHeight / self.unitData.picWidth;
        imageView.frame = CGRectMake(0, 0, imageViewBack.frame.size.width, imageHeight);
    } else{
        
        CGFloat imageWidth = imageViewBack.frame.size.height * self.unitData.picWidth / self.unitData.picHeight;
        imageView.frame = CGRectMake(0, 0, imageWidth, imageViewBack.frame.size.height);
    }

    NSString* imageViewURL = [self.unitData.picURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageViewURL]];
    [imageViewBack addSubview:imageView];
    
    return smallPictureBack;
}

- (UIView*) setupTopView{
    
    //导航栏位置添加顶部视图
    UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, SystemBarHeight+NavigationBarHeight)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    //给顶部视图添加左右两个按钮
    //左按钮
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    closeBtn.fy_x = 10;
    closeBtn.fy_centerY = SystemBarHeight + NavigationBarHeight/2;
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:closeBtn];
    
    //右按钮
    UIButton* OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [OKBtn setTitle:@"√" forState:UIControlStateNormal];
    [OKBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [OKBtn sizeToFit];
    OKBtn.fy_x = ScreenWidth - 10 - OKBtn.frame.size.width;
    OKBtn.fy_centerY = SystemBarHeight + NavigationBarHeight/2;
    [OKBtn addTarget:self action:@selector(OKBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:OKBtn];
    
    //添加中间标题内容
    UILabel* title = [[UILabel alloc] init];
    title.text = @"编辑作品";
    title.font = [UIFont systemFontOfSize:20];
    [title sizeToFit];
    title.fy_centerX = ScreenWidth/2;
    title.fy_centerY = SystemBarHeight + NavigationBarHeight/2;
    [topView addSubview: title];
    
    return topView;
}

- (void) closeBtnClicked{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) OKBtnClicked{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"WORKS_ADD_INFO";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    //取得图片的所有者
    paramData[@"owner"] = self.unitData.owner;
    //取得图片所属画板名
    paramData[@"drawName"] = self.unitData.templateName;
    //取得当前作品的数据库路径
    NSRange range = [self.unitData.picURL rangeOfString:@"photo/"];
    NSString* pictureUrl = [self.unitData.picURL substringFromIndex:(range.location + range.length)];
    paramData[@"picURL"] = pictureUrl;
    paramData[@"picDesc"] = self.gDescriptionTV.text;

    parameters[@"data"] = paramData;
    
    NSString* url = ServerURL;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest* req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    
    req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
            //NSLog(@"Reply JSON: %@", responseObject);
            NSInteger retValue = [responseObject[@"retCode"] integerValue];
            if (retValue > 0) {  //success
                
                self.gDescriptionTV.text = @"";
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{ //failure
                
                [SVProgressHUD showErrorWithStatus:@"处理错误"];
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [SVProgressHUD showErrorWithStatus:@"网络故障"];
        }
    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
