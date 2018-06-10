//
//  FYShowDetailDrawboardViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/5.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYShowDetailDrawboardViewController.h"
#import "CommonAttr.h"
#import <Masonry.h>
#import "UIView+Frame.h"
#import <UIImageView+WebCache.h>
#import "FYCollectionViewWaterFallLayout.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYDetailDrawboardColleCell.h"
#import "FYPersonalCenterViewController.h"
#import "FYDetailInfoController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "uploadModel.h"
#import "FYDisplayCell.h"
#import <SVProgressHUD.h>


#define DetailDrawboardCell @"DetailDrawboardCell"

#define Spacing 10

@interface FYShowDetailDrawboardViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* pictures;
@property(nonatomic, strong) UICollectionView* gCollec;

//上传图片
@property(nonatomic, retain) UIImagePickerController* imagePicker;
//待上传图片数组
@property(nonatomic, retain) NSMutableArray* uploadArray;
//已经上传图片数组
@property(nonatomic, retain) NSMutableArray* uploadedArray;

@property(nonatomic, retain) UIButton* gRegardBtn;

@end

@implementation FYShowDetailDrawboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = MainBackgroundColor;
    
    [self addNavRightButton];
    
    //产生屏幕上半部分视图
    UIView* drawHead = [self getDrawboardHead];
    
    //系统控件  --- 方案1
//    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.minimumLineSpacing = Spacing;
//    layout.minimumInteritemSpacing = Spacing;
    
    //暂时用系统的控件来实现。特异化留待后续更新  --- 方案2
    FYCollectionViewWaterFallLayout* layout = [[FYCollectionViewWaterFallLayout alloc] init];
    layout.data = self.pictures;
    
    UICollectionView* collec = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collec.delegate = self;
    collec.dataSource = self;
    collec.backgroundColor = [UIColor clearColor];
    //方案1
    //[collec registerNib:[UINib nibWithNibName:@"FYDetailDrawboardColleCell" bundle:nil] forCellWithReuseIdentifier:DetailDrawboardCell];
    //collec.contentInset = UIEdgeInsetsMake(drawHead.bounds.size.height + Spacing, Spacing, Spacing, Spacing);
    //方案2
    [collec registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:DetailDrawboardCell];
    collec.contentInset = UIEdgeInsetsMake(drawHead.bounds.size.height, 0, 0, 0);
    self.gCollec = collec;
    
    //collectionview上添加上半部分的固定视图
    //drawHead.frame = CGRectMake(-Spacing, -drawHead.bounds.size.height - Spacing, ScreenWidth, drawHead.bounds.size.height);   //方案1
    drawHead.frame = CGRectMake(0, -drawHead.bounds.size.height, ScreenWidth, drawHead.bounds.size.height);   //方案2
    [collec addSubview:drawHead];
    
    //背景视图上添加collectionview
    [self.view addSubview: collec];
    
    self.imagePicker.delegate = self;
    
    [self loadData];
}

- (void) addNavRightButton{
    
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* loginName = [userDef objectForKey:@"loginName"];
    
    if (self.userName.length && ![self.userName isEqualToString:loginName]) { //进入的是别人的个人中心
        
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        [btn setTitle:@"+关注" forState:UIControlStateNormal];
        [btn setTitle:@"✔️" forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(regardButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        self.gRegardBtn = btn;
        
        UIBarButtonItem  *barbtn = [[UIBarButtonItem alloc] initWithCustomView: btn];
        self.navigationItem.rightBarButtonItem = barbtn;
    }else{ //myself
        
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        [btn setTitle:@"➕" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
        [btn sizeToFit];
        [btn addTarget:self action:@selector(uploadPictureClicked) forControlEvents: UIControlEventTouchUpInside];
        
        UIBarButtonItem  *barbtn = [[UIBarButtonItem alloc] initWithCustomView: btn];
        self.navigationItem.rightBarButtonItem = barbtn;
    }
}

- (void) regardButtonStatus:(bool) isChoice{
    
    self.gRegardBtn.selected = isChoice;
    if (self.gRegardBtn.selected) {
        self.gRegardBtn.backgroundColor = [UIColor lightGrayColor];
    }else{
        self.gRegardBtn.backgroundColor = [UIColor redColor];
    }
}

//关注按钮被点击
- (void) regardButtonClicked:(UIButton*) btn{
    
    btn.selected = !btn.selected;
    if (btn.selected) {
        btn.backgroundColor = [UIColor lightGrayColor];
    }else{
        btn.backgroundColor = [UIColor redColor];
    }

    //更新数据库
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"DRAWBOARD_REGARD_OR_NOT";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //当前登录用户
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"loginUser"] = username;
    
    //被关注画板所属用户
    paramData[@"drawOwnerUser"] = self.userName;
    
    //被关注画板
    paramData[@"drawName"] = self.specifyDrawData.drawboardName;
    
    //关注还是取消关注
    paramData[@"regardOrNot"] = [NSString stringWithFormat:@"%zd", btn.selected];
    
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
            if (retValue == 0) {
                [SVProgressHUD showErrorWithStatus:@"处理错误"];
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [SVProgressHUD showErrorWithStatus:@"网络故障"];
        }
    }] resume];
}

//上传图片方法
- (void) uploadPictureClicked{
    
    //底部弹出选择照片控制器
    UIAlertController* alertContro = [UIAlertController alertControllerWithTitle:@"" message:@"上传图片" preferredStyle: UIAlertControllerStyleActionSheet];
    
    //从相册选择
    UIAlertAction* photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"从相册选择");
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
        self.imagePicker.allowsEditing = YES;
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    
    //从摄像头获取图片
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"拍照");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            self.imagePicker.allowsEditing = YES;
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        } else{
            
            NSLog(@"没有可用的摄像头");
        }
    }];
    
    //取消
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    
    [alertContro addAction:photoAction];
    [alertContro addAction:cameraAction];
    [alertContro addAction:cancelAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER_DETAILDRAWBOARD";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //其他用户
    if (self.userName.length) {
        paramData[@"otherUser"] = self.userName;
    }
    
    //登录用户
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"loginUser"] = username;
    
    //画板名
    paramData[@"drawName"] = self.specifyDrawData.drawboardName;
    
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
            [self.pictures removeAllObjects];
            
            //正确设置关注按钮的状态
            bool isAttention = [responseObject[@"isAttention"] boolValue];
            [self regardButtonStatus:isAttention];
            
            //
            [self.pictures addObjectsFromArray:[FYWorksUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"detailDrawbData"]]];
            [self.gCollec reloadData];

        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (UIView*) getDrawboardHead {
    
    CGFloat offsetY = 0;
    CGFloat spacing = 20;
    
    UIView* drawboardHead = [[UIView alloc] init];
    offsetY += spacing;
    
    //画板名
    UIView* drawNameView = [[UIView alloc] init];
    drawNameView.backgroundColor = [UIColor clearColor];
    [drawboardHead addSubview:drawNameView];
    
    UILabel* drawName = [[UILabel alloc] init];
    drawName.text = self.specifyDrawData.drawboardName;
    [drawName sizeToFit];
    drawName.backgroundColor = [UIColor clearColor];
    [drawNameView addSubview:drawName];
    
    drawNameView.frame = CGRectMake(0, offsetY, ScreenWidth, drawName.fy_height);
    drawName.fy_centerX = drawNameView.fy_centerX;
    drawName.fy_centerY = drawNameView.bounds.size.height/2;
    
    offsetY += drawNameView.bounds.size.height;
    
    //画板描述
    if (self.specifyDrawData.descriptionText.length) {
        offsetY += spacing;

        UILabel* drawDesc = [[UILabel alloc] init];
        drawDesc.fy_y = offsetY;
        drawDesc.fy_width = ScreenWidth;
        drawDesc.numberOfLines = 0;
        drawDesc.text = self.specifyDrawData.descriptionText;
        drawDesc.font = [UIFont systemFontOfSize:13];
        drawDesc.textColor = [UIColor grayColor];
        drawDesc.textAlignment = NSTextAlignmentCenter;
        [drawDesc sizeToFit];
        drawDesc.backgroundColor = [UIColor clearColor];
        [drawboardHead addSubview:drawDesc];
        drawDesc.fy_centerX = ScreenWidth/2;

        offsetY += drawDesc.bounds.size.height;
    }
    
    offsetY += spacing;
    
    //分割线
    UIView* separation = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, ScreenWidth - 20, 0.5)];
    separation.backgroundColor = [UIColor lightGrayColor];
    [drawboardHead addSubview:separation];
    offsetY += separation.bounds.size.height;
    
//    offsetY += spacing;
    
    //用户信息
    CGFloat userInfoHeight = CellHeadIconRadius * 2 + 20;
    UIView* userInfo = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, ScreenWidth, userInfoHeight)];
    userInfo.backgroundColor = [UIColor clearColor];
    
    //头像
    UIImageView* headIcon = [[UIImageView alloc] init];
    headIcon.backgroundColor = [UIColor grayColor];
    [userInfo addSubview:headIcon];
    [headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userInfo.mas_top).with.offset(10);
        make.left.equalTo(userInfo.mas_left).with.offset(10);
        make.bottom.equalTo(userInfo.mas_bottom).with.offset(-10);
        make.width.mas_equalTo(headIcon.mas_height).multipliedBy(1);
    }];
    NSString* headiconURL = [self.specifyDrawData.ownerHeadIcon stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [headIcon sd_setImageWithURL:[NSURL URLWithString:headiconURL] completed:nil];
//    NSString* headIconStr = [NSString stringWithFormat:@"http://192.168.1.101:8080/photo/%@/headicon/head.jpg", self.specifyDrawData.ownerUserName];
//    NSLog(@"headIconStr=%@", headIconStr);
    headIcon.layer.cornerRadius = (userInfoHeight - 20)/2;
    headIcon.layer.masksToBounds = YES;
    
    //给头像添加手势响应动作
    headIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeadIcon)];
    [headIcon addGestureRecognizer:tap];
    
    //用户名
    UILabel* userName = [[UILabel alloc] init];
    userName.text = self.specifyDrawData.ownerUserName;
    [userName sizeToFit];
    userName.fy_centerY = userInfoHeight/2;
    userName.fy_x = userInfoHeight;
    [userInfo addSubview: userName];

    //关注
    UILabel* attention = [[UILabel alloc] init];
    attention.text = [NSString stringWithFormat:@"%zd关注", self.specifyDrawData.attentionNum];
    attention.font = [UIFont systemFontOfSize:13];
    [attention sizeToFit];
    [userInfo addSubview:attention];
    [attention mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userName.mas_top).with.offset(0);
        make.right.equalTo(userInfo.mas_right).with.offset(-10);
    }];
    
    //中间小点
    UIView* dot = [[UIView alloc] init];
    dot.backgroundColor = [UIColor blueColor];
    [userInfo addSubview:dot];
    [dot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(attention.mas_top).with.offset(attention.bounds.size.height/2 - 1);
        make.right.equalTo(attention.mas_left).with.offset(-5);
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(2);
    }];
    
    //采集
    UILabel* collec = [[UILabel alloc] init];
    collec.text = [NSString stringWithFormat:@"%zd采集", self.specifyDrawData.picNums];
    collec.font = [UIFont systemFontOfSize:13];
    [collec sizeToFit];
    [userInfo addSubview:collec];
    [collec mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userName.mas_top).with.offset(0);
        make.right.equalTo(dot.mas_left).with.offset(-5);
    }];
    
    [drawboardHead addSubview:userInfo];
    offsetY += userInfo.bounds.size.height;

    drawboardHead.frame = CGRectMake(0, 0, ScreenWidth, offsetY);
    drawboardHead.backgroundColor = [UIColor whiteColor];
    
    return drawboardHead;
}

- (void) clickedHeadIcon{
    
    FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
    pcVC.userName = self.specifyDrawData.ownerUserName;
    
    [self.navigationController pushViewController:pcVC animated:YES];
}

//懒加载
- (NSMutableArray<FYWorksUnitData*>*) pictures{
    
    if (!_pictures) {
        
        _pictures = [NSMutableArray<FYWorksUnitData*> array];
    }
    
    return _pictures;
}

- (UIImagePickerController*) imagePicker{
    
    if (!_imagePicker) {
        
        _imagePicker = [[UIImagePickerController alloc] init];
    }
    
    return _imagePicker;
}

- (NSMutableArray*) uploadArray{
    
    if (!_uploadArray) {
        
        _uploadArray = [NSMutableArray array];
    }
    
    return _uploadArray;
}

- (NSMutableArray*) uploadedArray{
    
    if (!_uploadedArray) {
        
        _uploadedArray = [NSMutableArray array];
    }
    
    return _uploadedArray;
}

//代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.pictures.count;
}

//方案1
//- (FYDetailDrawboardColleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    FYDetailDrawboardColleCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DetailDrawboardCell forIndexPath:indexPath];
//
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.pictures[indexPath.item].picURL] completed:nil];
//
//
//    return cell;
//}

//方案2
- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DetailDrawboardCell forIndexPath:indexPath];
    
    FYWorksUnitData* data = self.pictures[indexPath.item];
    NSString* workURL = [data.picURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.workImage sd_setImageWithURL:[NSURL URLWithString:workURL] completed:nil];
    
    //转发数量
    NSString* zhuanCaiTxt = data.forwardCount > 0 ? [NSString stringWithFormat:@"%zd", data.forwardCount] : @"";
    cell.zhuanCaiLabel.text = zhuanCaiTxt;
    
    //喜欢数量
    NSString* loveTxt = data.likeCount > 0 ? [NSString stringWithFormat:@"%zd", data.likeCount] : @"";
    cell.loveLabel.text = loveTxt;
    
    //评论数量
    NSString* commentTxt = data.commentCount > 0 ? [NSString stringWithFormat:@"%zd", data.commentCount] : @"";
    cell.commentLabel.text = commentTxt;
    
    cell.descriptionLabel.text = data.descriptionText;
    NSString* headiconURL = [data.headIcon stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.headerIcon sd_setImageWithURL:[NSURL URLWithString:headiconURL] completed:nil];
    cell.usernameLabel.text = data.owner;
    cell.workModuleLabel.text = data.templateName;
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath item];
    
    CGFloat itemWidth = (ScreenWidth - Spacing * 3)/2;
    CGFloat itemHeight = itemWidth * self.pictures[index].picHeight / self.pictures[index].picWidth;
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDetailInfoController* infoVC = [[FYDetailInfoController alloc] init];
    infoVC.unitData = self.pictures[indexPath.item];
    infoVC.hasRecommend = NO;
    
    [self.navigationController pushViewController:infoVC animated:YES];
}

//UIImagePickerController 代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //获取用户选择的是照片还是视频
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    
    //如果是照片
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        
        //获取编辑后的照片
        NSLog(@"获取编辑后的照片");
        UIImage* tempImage = info[UIImagePickerControllerEditedImage];   //获取编辑后的图片
        //UIImage* tempImage = info[UIImagePickerControllerOriginalImage];   //获取原始图片
        
        //将照片存入相册
        if (tempImage) {
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                
                //将照片存入相册
                NSLog(@"将照片存入相册");
                UIImageWriteToSavedPhotosAlbum(tempImage, self, nil, nil);
            }
            
            //获取图片名称
            NSLog(@"获取图片名称");
            NSString* imageName = [self getImageNameBaseCurrentTime];
            NSLog(@"图片名称: %@", imageName);
            
            //将图片存入缓存
            NSLog(@"将图片存入缓存");
            [self saveImage:tempImage toCachePath:[PHOTOCACHEPATH stringByAppendingPathComponent:imageName]];
            
            //创建uploadModel
            NSLog(@"创建uploadModel");
            uploadModel* model = [[uploadModel alloc] init];
            
            model.path = [PHOTOCACHEPATH stringByAppendingPathComponent:imageName];
            model.name = imageName;
            model.type = @"image";
            model.isUploaded = NO;
            
            //将模型model存入待上传数组
            NSLog(@"将模型model存入待上传数组");
            [self.uploadArray addObject:model];
            
            //上传图片
            [self uploadImageBaseModel:model];
        }
    }
    else{ //其他。-- 视频
        
        NSLog(@"其他。-- 视频");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) uploadImageBaseModel:(uploadModel*) model{
    
    //获取文件的后缀名
    NSString* extension = [model.name componentsSeparatedByString:@"."].lastObject;
    
    //设置mimeType
    NSString* mimeType;
    if ([model.type isEqualToString:@"image"]) {
        
        mimeType = [NSString stringWithFormat:@"image/%@", extension];
    } else{ //视频
        
        mimeType = [NSString stringWithFormat:@"video/%@", extension];
    }
    
    //创建AFHTTPSessionManager
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    //设置响应文件类型为JSON类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //初始化requestSerializer
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = nil;
    
    //设置timeout
    [manager.requestSerializer setTimeoutInterval:20.0];
    
    //设置请求头类型
    [manager.requestSerializer setValue:@"form/data" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setStringEncoding: NSUTF8StringEncoding];
    
    //设置请求头， 授权码
    //[manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authentication"];
    
    //上传服务器接口
    NSString* url = ServerURL;
    
    
    //参数
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER_DRAWBOARD";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];

    //用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    
    //画板名字
    paramData[@"drawname"] = self.specifyDrawData.drawboardName;
    
    paramData[@"picType"] = @"PicTypeWorks";
    
    parameters[@"data"] = paramData;
    
    //开始上传
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError* error;
        BOOL ret = [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.path] name:model.name fileName:model.name mimeType:mimeType error:&error];
        
        if (!ret) {
            
            NSLog(@"appendPartWithFileURL error: %@", error);
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"上传进度: %f", uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"成功返回: %@", responseObject);
        NSInteger ret = [responseObject[@"retCode"] integerValue];
        if (ret > 0) {
            
            [self loadData];
        }
        
        model.isUploaded = YES;
        [self.uploadedArray addObject:model];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传失败: %@", error);
        model.isUploaded = NO;
    }];
}

//工具方法
- (NSString*) getImageNameBaseCurrentTime{
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    return [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".jpg"];
}
             
- (void) saveImage:(UIImage*) image toCachePath:(NSString*) path{
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:PHOTOCACHEPATH]) {
        
        NSLog(@"路径不存在，创建路径");
        [fileManager createDirectoryAtPath:PHOTOCACHEPATH withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        NSLog(@"路径存在");
    }
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
