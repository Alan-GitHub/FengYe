//
//  FYNewDrawboardViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/26.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYNewDrawboardViewController.h"
#import "CommonAttr.h"
#import "UITextView+Placeholder.h"
#import <AFNetworking.h>

#define TableViewID @"TableViewID"
#define FirstCellHeight 50
#define SecondCellHeight 100

@interface FYNewDrawboardViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, retain) UITextField* gTextField;
@property(nonatomic, retain) UITextView* gTextView;

@end

@implementation FYNewDrawboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"添加画板";
    
    //添加左按钮
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonSystemItemCancel target:self action:@selector(leftBtnAction)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //添加右按钮
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"√" style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //添加表视图
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void) leftBtnAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) rightBtnAction{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER_ADDDRAWBOARD";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    paramData[@"drawboardName"] = self.gTextField.text;
    paramData[@"drawboardDesc"] = self.gTextView.text;
    
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
            //retCode
            //0 - success, 1 - failure
            int retCode = [responseObject[@"retCode"] intValue];
            
            if (retCode == 0) { //success
                
                FYDrawboardCellUnitData* dbCell = [[FYDrawboardCellUnitData alloc] init];

                dbCell.drawboardName = self.gTextField.text;
                dbCell.descriptionText = self.gTextView.text;
                
                [self.drawboardVC.dataAttr addObject:dbCell];
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.drawboardVC.gDboardColleView reloadData];
    }];
}

//代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:TableViewID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewID];
    }

    NSInteger index = [indexPath row];
    switch (index) {
        case 0:
            {
                UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, ScreenWidth, FirstCellHeight)];
                textField.placeholder = @"画板名称";
                self.gTextField = textField;
                [cell addSubview:textField];
            }
            break;
            
        case 1:
            {
                UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, SecondCellHeight)];
                textView.font = [UIFont systemFontOfSize:18];
                [textView setPlaceholder:@"  画板描述" placeholdColor:[UIColor lightGrayColor]];
                self.gTextView = textView;
                [cell addSubview:textView];
            }
            break;

        default:
            break;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath row];
    CGFloat height = 0;
    
    switch (index) {
        case 0:
            height = FirstCellHeight;
            break;
            
        case 1:
            height = SecondCellHeight;
            break;
            
        default:
            break;
    }
    
    return height;
}

//textField代理
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [textField becomeFirstResponder];
}

//textview代理
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    [textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
