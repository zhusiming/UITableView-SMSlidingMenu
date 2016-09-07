//
//  ViewController.m
//  UITableView+SMSlidingMenu
//
//  Created by 朱思明 on 16/9/5.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 568) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.slidingMenuDelegate = self;
    tableView.slidingMenutype = SMSlidingMenuTypeRoundedCorner;
    tableView.slidingMenuLineSpacing = 10;
    [self.view addSubview:tableView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"row:%d",indexPath.row + 1];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"section:%d",section + 1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView removeFromSuperview];
}

#pragma mark - SMTableViewSlidingMenuDelegate
- (nullable NSArray<NSString *> *)slidingMenuSectionIndexTitlesForTableView:(UITableView *)tableView
{
    return @[@"a",@"b",@"c",@"d"];
}
- (NSInteger)tableView:(UITableView *)tableView slidingMenuSectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSLog(@"%d",index);
    return index + 1;
}
@end
