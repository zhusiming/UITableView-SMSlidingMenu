//
//  UITableView+SMSlidingMenu.h
//  UITableView+SMSlidingMenu
//
//  Created by 朱思明 on 16/9/5.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
// 定义枚举类型
typedef enum{
    SMSlidingMenuTypeNone ,
    SMSlidingMenuTypeRoundedCorner
} SMSlidingMenuType;

// 定义获取滑动菜单数据代理协议
@protocol SMTableViewSlidingMenuDelegate <NSObject>

@required
/*
 *  设置右侧菜单按钮内容数组
 */
- (nullable NSArray<NSString *> *)slidingMenuSectionIndexTitlesForTableView:( UITableView * _Nullable )tableView;

@optional
/*
 *  根据点击菜单的文本和索引位置，来制定表视图制定滑动到组的位置
 *  注意： 如实现了此协议，表视图的组滚动位置完全手动设置。 否则：表视图会自动滚到到点击索引对应的组
 */
- (NSInteger)tableView:(UITableView * _Nullable)tableView slidingMenuSectionForSectionIndexTitle:( NSString * _Nullable)title atIndex:(NSInteger)index;

@end

@interface UITableView (SMSlidingMenu)

/*
 *  代理对象
 */
@property (nonatomic, weak) id<SMTableViewSlidingMenuDelegate> _Nullable slidingMenuDelegate;

/*
 *  设置滑动菜单视图文本颜色    
 *  default:[UIColor blueColor]
 */
@property (nonatomic, strong) UIColor * _Nullable slidingMenuTitleColor;

/*
 *  设置滑动菜单视图文本背景颜色  
 *  default:[UIColor colorWithWhite:.5 alpha:.5]
 */
@property (nonatomic, strong) UIColor * _Nullable slidingMenuBackgroudColor;

/*
 *  设置滑动菜单视图文本背景颜色
 *  default:[UIColor colorWithWhite:.5 alpha:.7]
 */
@property (nonatomic, strong) UIColor * _Nullable slidingMenuHighlightBackgroudColor;

/*
 *  设置滑动菜单视图样式         
 *  default:SMSlidingMenuTypeNone
 */
@property (nonatomic, assign) SMSlidingMenuType slidingMenutype;

/*
 *  设置滑动菜单视图文字字体大小
 *  default:12
 */
@property (nonatomic, assign) CGFloat slidingMenuFontSize;

/*
 *  设置滑动菜单视图样式文字间距
 *  default:0
 */
@property (nonatomic, assign) CGFloat slidingMenuLineSpacing;

@end
