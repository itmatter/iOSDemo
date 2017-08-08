//
//  ViewController.m
//  CoreDataTable
//
//  Created by 李礼光 on 2017/7/24.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Person+CoreDataClass.h"

#import "MYCell.h"
#import "ChangeVC.h"

static NSString *sqlName = @"myCoreData";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSManagedObjectContext *context;   ///管理对象上下文      负责管理模型的对象集合
@property (nonatomic, strong) NSManagedObjectModel *model;       ///管理对象模型        负责管理对象模型
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc; ///持久化存储调度器     负责将数据保存到磁盘的操作
//简单粗暴理解:
//_context提供一个平台给管理对象,管理对象根据自己创建的model,调用_psc来对这个模型的数据进行增删改查,最终修改到本地存储的内容.

@property (nonatomic, strong) Person *selectedPerson;
@end

@implementation ViewController

#pragma mark - 懒加载
- (NSMutableArray *)dataArr {
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSManagedObjectContext *)context {
    if (_context == nil) {
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _context.persistentStoreCoordinator = self.psc;
    }
    return _context;
}

- (NSPersistentStoreCoordinator *)psc {
    if (_psc == nil) {
        _psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.model];
        NSString *dataBaseFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.sqlite",sqlName]];
        NSURL *storeUrl = [NSURL fileURLWithPath:dataBaseFilePath];
        //添加存储器
        //Type:存储类型, 数据库/XML/二进制/内存
        //configuration:不需要额外配置,可以为nil
        //URL:数据保存的文件的URL 这里我们放到documents里
        [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:nil];
    }
    return _psc;
}

- (NSManagedObjectModel *)model {
    if (_model == nil) {
        NSURL *entityFilePath = [[NSBundle mainBundle] URLForResource:@"CoreDataTable" withExtension:@"momd"];
        if (entityFilePath == nil) {
            NSLog(@"数据模型创建失败");
            return nil;
        }
        _model = [[NSManagedObjectModel alloc]initWithContentsOfURL:entityFilePath];
    }
    return _model;
}

#pragma mark - 系统方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self check];
    [self setupTableView];
    [self setupRightNavBarButtonItem];
    self.title = @"CoreDataDemo";
}

- (void)setupRightNavBarButtonItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"add" style:UIBarButtonItemStyleDone target:self action:@selector(addNew)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)setupTableView {
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerNib:[UINib nibWithNibName:@"MYCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"coreDataCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}


#pragma mark - 增删改查操作
int i = 0;
- (void)addNew {
    Person *p = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
    p.name = [NSString stringWithFormat:@"Test%d",i++];
    p.age = i;
    p.sex = @"man";
    [self.context save:nil];
    [self.dataArr addObject:p];
    [_tableView reloadData];
}

- (void)deleteCoreData:(NSUInteger)index{
    Person *p = self.dataArr[index];
    NSString * deleteContent = p.name;
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",deleteContent];
    NSEntityDescription * des = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context];
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = des;
    request.predicate = pre;
    NSArray * array = [self.context executeFetchRequest:request error:NULL];
    NSLog(@"arr : r%@",array);
    for (Person * p in array) {
        [self.context deleteObject:p];
    }
    [self.context save:nil];
    
}

- (void)updateCoreData: (NSString *)name age:(NSString *)age sex:(NSString *)sex {
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",_selectedPerson.name];
    NSEntityDescription * des = [NSEntityDescription entityForName:@"Person"
                                            inManagedObjectContext:self.context];
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = des;
    request.predicate = pre;
    NSArray * array = [self.context executeFetchRequest:request error:NULL];
    self.dataArr = nil;
    for (Person * p in array) {
        p.name = name;
        p.age = age.integerValue;
        p.sex = sex;
        //更新数据库的内容
        [self.context updatedObjects];
    }
    //更新数组内容.
    for (Person * pArr in self.dataArr) {
        pArr.name = name;
        pArr.age = age.integerValue;
        pArr.sex = sex;
    }
    [self.context save:nil];
    [self check];              
    
}

- (void)check {
    //查找所有内容
    NSString *searchContent = @"";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",searchContent];
    if (searchContent.length == 0) {
        pre = nil;
    }
    NSEntityDescription * des = [NSEntityDescription entityForName:@"Person"
                                            inManagedObjectContext:self.context];
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = des;
    request.predicate = pre;
    NSArray * array = [_context executeFetchRequest:request error:NULL];
    self.dataArr = nil;
    for (Person * p in array) {
        [self.dataArr addObject:p];
    }
}

#pragma mark - tableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MYCell *cell = [tableView dequeueReusableCellWithIdentifier:@"coreDataCell"];
    Person *p = self.dataArr[indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"Name : %@",p.name];
    cell.ageLabel.text = [NSString stringWithFormat:@"Age : %lld",p.age];
    cell.sexLabel.text = [NSString stringWithFormat:@"Name : %@",p.sex];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteCoreData:indexPath.row];
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedPerson = self.dataArr[indexPath.row];
    [self showChangeView:_selectedPerson];
}



- (void)showChangeView:(Person *)person {
    ChangeVC *changVC = [[ChangeVC alloc]init];
    changVC.superiorVC = self;
    changVC.person = _selectedPerson;
    [self presentViewController:changVC animated:NO completion:^{
        
    }];
}



@end




