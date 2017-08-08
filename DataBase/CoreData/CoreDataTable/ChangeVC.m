//
//  ChangeVC.m
//  CoreDataTable
//
//  Created by 李礼光 on 2017/7/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "ChangeVC.h"

@interface ChangeVC ()

@end

@implementation ChangeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)comfirmBtn:(id)sender {
    NSString *name;
    NSString *age;
    NSString *sex;
    if (self.nameTF.text.length == 0) {
        name = self.person.name;
    }else {
        name = self.nameTF.text;
    }
    if (self.ageTF.text.length == 0) {
        age = [NSString stringWithFormat:@"%lld",self.person.age];
    }else {
        age = self.ageTF.text;
    }
    if (self.sexTF.text.length == 0) {
        sex = self.person.sex;
    }else {
        sex = self.sexTF.text;
    }
    
    [self.superiorVC updateCoreData:name
                                age:age
                                sex:sex];
    [self.superiorVC check];
    [self.superiorVC.tableView reloadData];
    [self cancleBtn:nil];
}
- (IBAction)cancleBtn:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
