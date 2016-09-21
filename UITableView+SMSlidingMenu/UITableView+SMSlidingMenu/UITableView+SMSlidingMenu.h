//
//  UITableView+SMSlidingMenu.h
//  UITableView+SMSlidingMenu
//
//  Created by 朱思明 on 16/9/5.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/*
 *  默认视图属性设置
 */
#define kSMSlidingMenu_width 24                 // 视图宽度
#define kSMSlidingMenu_right_margin 10          // 视图右侧间距
#define kSMSlidingMenu_top_margin 20            // 视图上部上边距
#define kSMSlidingMenu_bottom_margin 20         // 视图底部下边距
#define kSMSlidingMenu_autoShowAfterDelay 2     // 开启自动隐藏和显示功能，延迟隐藏功能调用的时间


// 定义枚举类型
typedef enum{
    SMSlidingMenuTypeNone,                      // 默认样式
    SMSlidingMenuTypeRoundedCorner              // 圆角样式
} SMSlidingMenuType;

typedef enum{
    SliderMenuItemTypeText,                     // 文本数据
    SliderMenuItemTypeImage                     // 图片数据
} SliderMenuItemType;


#pragma mark -
#pragma mark - 数据代理类定义
@interface SliderMenuItem: NSObject

/*
 *  创建一个图片类型数据
 */
+ (SliderMenuItem * __nonnull)typeImageWithImageName:(NSString * __nonnull)content;

/*
 *  创建一个文本类型数据
 */
+ (SliderMenuItem * __nonnull)typeTextWithTitle:(NSString * __nonnull)content;
@end


#pragma mark -
#pragma mark - 定义获取滑动菜单数据代理协议
@protocol SMTableViewSlidingMenuDelegate <NSObject>

@required
/*
 *  设置右侧菜单按钮内容数组
 */
- (nullable NSArray<SliderMenuItem *> *)slidingMenuSectionIndexTitlesForTableView:( UITableView * _Nullable )tableView;

@optional
/*
 *  根据点击菜单的文本和索引位置，来制定表视图制定滑动到组的位置
 *  注意： 如实现了此协议，表视图的组滚动位置完全手动设置。 否则：表视图会自动滚到到点击索引对应的组
 */
- (NSInteger)tableView:(UITableView * _Nullable)tableView slidingMenuSectionForSectionIndexItem:( SliderMenuItem * _Nullable)item atIndex:(NSInteger)index;

@end


#pragma mark -
#pragma mark - 表视图类目
@interface UITableView (SMSlidingMenu)

/*
 *  代理对象
 */
@property (nonatomic, weak) id<SMTableViewSlidingMenuDelegate> _Nullable slidingMenuDelegate;

/*
 *  设置滑动菜单视图文本颜色
 *  default:[UIColor grayColor]
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
 *  default:10
 */
@property (nonatomic, assign) CGFloat slidingMenuFontSize;

/*
 *  设置滑动菜单视图样式文字间距
 *  default:2
 */
@property (nonatomic, assign) CGFloat slidingMenuLineSpacing;

/*
 *  设置滑动菜单视图自动显示:当视图滑动时视图显示，当手指离开视图的时候自动隐藏
 *  default:NO
 */
@property (nonatomic, assign) BOOL slidingMenuAutoShow;

@end
