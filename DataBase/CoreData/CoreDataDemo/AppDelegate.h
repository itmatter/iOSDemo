//
//  AppDelegate.h
//  CoreDataDemo
//
//  Created by 李礼光 on 2017/7/21.
//  Copyright © 2017年 LG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

