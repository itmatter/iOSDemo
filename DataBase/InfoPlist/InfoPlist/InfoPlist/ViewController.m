//
//  ViewController.m
//  InfoPlist
//
//  Created by 李礼光 on 2017/8/8.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *textF;
@property (strong, nonatomic) IBOutlet UITextField *text;

@property (nonatomic, strong) NSArray *plistContent;
@property (nonatomic, strong) NSString *plistPath;
@end

@implementation ViewController

- (NSArray *)plistContent {
    if (_plistContent == nil) {
        _plistContent = [NSArray array];
    }
    return _plistContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlist];
    [self check];
    [self changePlist];
    [self check];
    [self removePlist];
}






//增 -- 添加一个plist文件
- (void)createPlist {
    NSArray *sandboxpath= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [sandboxpath objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"sandbox.plist"];
    NSMutableDictionary *rootDic = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *userDataDic = [[NSMutableDictionary alloc]init];
    [userDataDic setObject:@"user" forKey:@"UserName"];
    [userDataDic setObject:@"psw" forKey:@"UserPassWord"];
    [rootDic setObject:userDataDic forKey:@"Login"];
    [rootDic writeToFile:plistPath atomically:YES];
    NSLog(@"%@",NSHomeDirectory());
    NSLog(@"写入成功");
}

//删
- (void)removePlist {
    NSFileManager *manager=[NSFileManager defaultManager];
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"sandbox.plist"];
    if ([manager removeItemAtPath:filepath error:nil]) {
        NSLog(@"文件删除成功");
    }
}

//改
- (void)changePlist {
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"sandbox.plist"];
    NSMutableDictionary *datalist= [[[NSMutableDictionary alloc]initWithContentsOfFile:filepath]mutableCopy];
    NSMutableDictionary *loginData = [datalist objectForKey:@"Login"];
    [loginData setValue: @"11111" forKey:@"UserName"];
    [loginData setValue: @"22222" forKey:@"UserPassWord"];
    [datalist setValue:loginData forKey:@"Login"];
    [datalist writeToFile:filepath atomically:YES];
    NSLog(@"修改成功");
}
//查
- (void)check {
    NSArray *sandboxpath= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[sandboxpath objectAtIndex:0] stringByAppendingPathComponent:@"sandbox.plist"];
    NSLog(@"%@",NSHomeDirectory());
    NSMutableDictionary *searchdata = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSLog(@"%@",searchdata);
}





@end
