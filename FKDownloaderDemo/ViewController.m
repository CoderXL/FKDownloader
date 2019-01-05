//
//  ViewController.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "ViewController.h"
#import "TaskListController.h"
#import "FKDownloader.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) FKSingleTask *task;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.button = [[UIButton alloc] init];
    [self.button setTitle:@"查看下载列表" forState: UIControlStateNormal];
    [self.button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(pushTaskList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.task = [[[[[[FKSingleTask taskWithLink:@"http://m4.pc6.com/cjh3/deliver259.dmg"] status:^(FKSingleTask * _Nonnull task) {
        NSLog(@"状态改变");
    }] progress:^(FKSingleTask * _Nonnull task) {
        NSLog(@"进度改变");
    }] success:^(FKSingleTask * _Nonnull task) {
        NSLog(@"完成");
    }] faild:^(FKSingleTask * _Nonnull task) {
        NSLog(@"失败");
    }] start];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.button.frame = CGRectMake(0, 200, self.view.bounds.size.width, 30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushTaskList {
    /*
    TaskListController *listController = [[TaskListController alloc] init];
    [self.navigationController pushViewController:listController animated:YES];
     */
}

@end
