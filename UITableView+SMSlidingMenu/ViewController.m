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
    cell.textLabel.text = [NSString stringWithFormat:@"row:%ld",indexPath.row + 1];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"section:%ld",section + 1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView removeFromSuperview];
}

#pragma mark - SMTableViewSlidingMenuDelegate
/*
 *  设置右侧菜单按钮内容数组
 */
- (nullable NSArray<SliderMenuItem *> *)slidingMenuSectionIndexTitlesForTableView:( UITableView * _Nullable )tableView
{
    return @[[SliderMenuItem typeImageWithImageName:@"SMSlidingMenu.bundle/friend_icon_search.png"],
             [SliderMenuItem typeTextWithTitle:@"A"],
             [SliderMenuItem typeTextWithTitle:@"B"],
             [SliderMenuItem typeTextWithTitle:@"C"]];
}


/*
 *  根据点击菜单的文本和索引位置，来制定表视图制定滑动到组的位置
 *  注意： 如实现了此协议，表视图的组滚动位置完全手动设置。 否则：表视图会自动滚到到点击索引对应的组
 */
- (NSInteger)tableView:(UITableView * _Nullable)tableView slidingMenuSectionForSectionIndexItem:( SliderMenuItem * _Nullable)item atIndex:(NSInteger)index
{
    return index ;
}

@end
