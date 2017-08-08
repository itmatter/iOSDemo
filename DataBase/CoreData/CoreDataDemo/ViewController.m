//
//  ViewController.m
//  CoreDataDemo
//
//  Created by 李礼光 on 2017/7/21.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "ViewController.h"
#import "Person+CoreDataClass.h"


typedef enum : NSUInteger {
    kCheckName = 0,
    kCheckAge,
    kCheckSex,
} CheckType;


@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTF;
@property (strong, nonatomic) IBOutlet UITextField *sexTF;
@property (strong, nonatomic) IBOutlet UITextField *ageTF;
@property (strong, nonatomic) IBOutlet UITextView *resultTF;


@property (nonatomic, strong) UIView *showAllView;
@property (nonatomic, assign) CheckType checkType;

@end

@implementation ViewController {
    NSManagedObjectContext *_context;   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCoreData];
}




- (IBAction)add:(id)sender {
    if ([_nameTF.text isEqual: @""] || [_sexTF.text isEqual: @""] || [_ageTF.text isEqual: @""]) {
        self.resultTF.text = @"请确认输入信息";
        return;
    }
    
    [self addUserDataWithName:_nameTF.text Sex:_sexTF.text Age:_ageTF.text.integerValue];
    
}
- (IBAction)delete:(id)sender {
}
- (IBAction)change:(id)sender {
}
- (IBAction)check:(id)sender {
    if (![_nameTF.text isEqualToString:@""]) {
        [self checkPersonWithContent:_nameTF.text];
        _checkType = kCheckName;
    }else if (![_ageTF.text isEqualToString:@""]) {
        [self checkPersonWithContent:_ageTF.text];
        _checkType = kCheckAge;
        NSLog(@"2");
    }else if (![_sexTF.text isEqualToString:@""]) {
        [self checkPersonWithContent:_sexTF.text];
        _checkType = kCheckSex;
        NSLog(@"3");
    }else {
        [self checkPersonWithContent:_nameTF.text];
        _checkType = kCheckName;
    }
}



//CoreData简单创建流程
//
//模型文件操作
//  1.1 创建模型文件，后缀名为.xcdatamodeld。创建模型文件之后，可以在其内部进行添加实体等操作(用于表示数据库文件的数据结构)
//  1.2 添加实体(表示数据库文件中的表结构)，添加实体后需要通过实体，来创建托管对象类文件。
//  1.3 添加属性并设置类型，可以在属性的右侧面板中设置默认值等选项。(每种数据类型设置选项是不同的)
//  1.4 创建获取请求模板、设置配置模板等。
//  1.5 根据指定实体，创建托管对象类文件(基于NSManagedObject的类文件)
//
//实例化上下文对象
//  2.1 创建托管对象上下文(NSManagedObjectContext)
//  2.2 创建托管对象模型(NSManagedObjectModel)
//  2.3 根据托管对象模型，创建持久化存储协调器(NSPersistentStoreCoordinator)
//  2.4 关联并创建本地数据库文件，并返回持久化存储对象(NSPersistentStore)
//  2.5 将持久化存储协调器赋值给托管对象上下文，完成基本创建。


- (void)initCoreData {
    //1.创建数据库文件路径
    NSString *dataBaseFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Person.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:dataBaseFilePath];
    NSLog(@"dataBaseFilePath : %@",dataBaseFilePath);
    
    //2.创建描述文件
    // .xcdatamodel中操作
    
    //3.读取实体描述文件,创建数据模型
    NSURL *entityFilePath = [[NSBundle mainBundle] URLForResource:@"CoreDataDemo" withExtension:@"momd"];
    if (entityFilePath == nil) {
        NSLog(@"数据模型创建失败");
        self.resultTF.text = @"数据模型创建失败";
        return;
    }
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:entityFilePath];
    
    //4.创建数据持久化协调器
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //5.添加数据持久层(创建数据库)
    NSError *error;
    [psc addPersistentStoreWithType:NSSQLiteStoreType       //数据持久化类型
                      configuration:nil                     //配置
                                URL:storeUrl                //数据持久化保存磁盘地址
                            options:nil                     //选项
                              error:&error];                //错误信息
    if (error) {
        NSLog(@"创建数据库失败,error : %@",error);
    }
    
    // Context
    _context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    _context.persistentStoreCoordinator = psc;
    
    //创建完毕之后,系统会自动创建ZUSERMODEL中的字段
    //ZUSERNAME,ZPASSWORD,ZAGE
}


- (void)addUserDataWithName:(NSString *)name Sex:(NSString *)sex Age:(NSUInteger)age {
    //1.创建用户对象
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                   inManagedObjectContext:_context];
    person.name = name;
    person.sex = sex;
    person.age = age;
    
    //保存对象
    NSError *error;
    [_context save:&error];
    if (error) {
        NSLog(@"添加失败%@",error);
        self.resultTF.text = [NSString stringWithFormat:@"添加失败 : %@",error];
    }else {
        self.resultTF.text = [NSString stringWithFormat:@"添加成功 "];
    }
}

- (void)checkPersonWithContent : (NSString *)content {
    
    _resultTF.text = @"请输入需要查找的内容.默认显示全部";
    
    _showAllView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 20)];
    [self.view addSubview: _showAllView];
    
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(10, 10, _showAllView.bounds.size.width - 20, _showAllView.bounds.size.height - 20);
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"";
    label.backgroundColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    [_showAllView addSubview:label];
    
    //查找所有内容
    NSString *searchContent = content;
    NSPredicate *pre;
    if (_checkType == kCheckName) {
        pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",searchContent];
    }else if (_checkType == kCheckAge){
        pre = [NSPredicate predicateWithFormat:@"age CONTAINS %@",searchContent];
    }else if (_checkType == kCheckSex) {
        pre = [NSPredicate predicateWithFormat:@"sex CONTAINS %@",searchContent];
    }
    
    //谓词使用小结:
    //1.谓词中的匹配指令关键字通常使用大写字母
    //2.谓词中可以使用格式字符串
    //3.如果通过对象的key path指定匹配条件,需要使用%k
    //  BEGANWITH : 以指定字符开始
    //  ENDSWITH : 以指定字符结束
    //  CONTAINS : 包含指定字符,可使用修饰符
    //      c 不区分大小写
    //      d 不区分注音符号
    //  LINE : 使用通配符匹配
    //      ? 一个字符
    //      * 0个或多个字符
    
    
    if (searchContent.length == 0) {
        pre = nil;
    }
    
    NSEntityDescription * des = [NSEntityDescription entityForName:@"Person"
                                            inManagedObjectContext:_context];
    
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = des;
    request.predicate = pre;
    
    NSArray * array = [_context executeFetchRequest:request error:NULL];
    for (Person * p in array) {
        label.text = [label.text stringByAppendingString:[NSString stringWithFormat:@"name : %@     age : %lld      sex:  %@\n",p.name,p.age,p.sex]];
    }
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = _showAllView.bounds;
    back.backgroundColor = [UIColor clearColor];
    [back addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_showAllView addSubview:back];
}

- (void)dismiss {
    if (_showAllView) {
        [_showAllView removeFromSuperview];
    }
}








@end
