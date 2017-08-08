//
//  ChangeVC.h
//  CoreDataTable
//
//  Created by 李礼光 on 2017/7/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Person+CoreDataClass.h"

@interface ChangeVC : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *nameTF;
@property (strong, nonatomic) IBOutlet UITextField *ageTF;
@property (strong, nonatomic) IBOutlet UITextField *sexTF;


@property (nonatomic, weak) ViewController *superiorVC;
@property (nonatomic, weak) Person *person;

@end
