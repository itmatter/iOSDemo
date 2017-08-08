//
//  ViewController.h
//  CoreDataTable
//
//  Created by 李礼光 on 2017/7/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, strong) UITableView *tableView;

- (void)check;
- (void)updateCoreData: (NSString *)name age:(NSString *)age sex:(NSString *)sex;
@end

