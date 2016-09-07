//
//  UITableView+SMSlidingMenu.m
//  UITableView+SMSlidingMenu
//
//  Created by 朱思明 on 16/9/5.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import "UITableView+SMSlidingMenu.h"
#import <objc/runtime.h>


/*
 *  默认视图属性设置
 */
#define kSMSlidingMenu_width 24
#define kSMSlidingMenu_right_margin 10
#define kSMSlidingMenu_top_margin 50

#pragma mark -
#pragma mark - 文本事件协议方法
@protocol SliderMenuLabelDelegate <NSObject>
@optional
// 点击开始
- (void)sliderMenuLabelTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
// 点击移动
- (void)sliderMenuLabelTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
// 点击结束
- (void)sliderMenuLabelTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
// 点击取消
- (void)sliderMenuLabelTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

#pragma mark -
#pragma mark - 文本自类化定义和实现

@interface SliderMenuLabel: UILabel
/*
 *  代理对象
 */
@property (nonatomic, weak) id<SliderMenuLabelDelegate> _Nullable delegate;
@end

@implementation SliderMenuLabel
// 点击开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate sliderMenuLabelTouchesBegan:touches withEvent:event];
}

// 点击移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate sliderMenuLabelTouchesMoved:touches withEvent:event];
}

// 点击结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate sliderMenuLabelTouchesEnded:touches withEvent:event];
}

// 点击取消
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate sliderMenuLabelTouchesCancelled:touches withEvent:event];
}
@end


#pragma mark -
#pragma mark - 表视图类延展和声明

@interface UITableView ()<SliderMenuLabelDelegate>

/*
 *  滑动文本视图
 */
@property (nonatomic, strong, readonly) SliderMenuLabel *slidingMenuLabel;
/*
 *  滑动文本视图内容
 */
@property (nonatomic, strong) NSArray *slidingMenuTitles;

@end

#pragma mark -
#pragma mark - 表视图类目实现

@implementation UITableView (SMSlidingMenu)

// 定义属性的键值
const void *key_slidingMenuDelegate;        // 代理对象
const void *key_slidingMenuLabel;           // 菜单文本视图
const void *key_slidingMenuTitleColor;      // 菜单文本颜色
const void *key_slidingMenuBackgroudColor;  // 菜单文本视图背景颜色
const void *key_slidingMenuHighlightBackgroudColor;  // 菜单文本视图高亮背景颜色
const void *key_slidingMenutype;            // 菜单文本视图样式
const void *key_slidingMenuFontSize;        // 菜单文本字体大小
const void *key_slidingMenuLineSpacing;     // 菜单文本间距
const void *key_slidingMenuTitles;     // 菜单文本数据



#pragma mark - setter/getter
// 设置代理读写操作
- (void)setSlidingMenuDelegate:(id<SMTableViewSlidingMenuDelegate>)slidingMenuDelegate
{
    objc_setAssociatedObject(self, &key_slidingMenuDelegate, slidingMenuDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<SMTableViewSlidingMenuDelegate>)slidingMenuDelegate
{
    return objc_getAssociatedObject(self, &key_slidingMenuDelegate);
}

// 获取菜单文本视图
- (SliderMenuLabel *)slidingMenuLabel
{
    if (objc_getAssociatedObject(self, &key_slidingMenuLabel)) {
        return objc_getAssociatedObject(self, &key_slidingMenuLabel);
    } else {
        SliderMenuLabel *slidingMenuLabel = [[SliderMenuLabel alloc] initWithFrame:CGRectZero];
        slidingMenuLabel.delegate = self;
        slidingMenuLabel.numberOfLines = 0;
        slidingMenuLabel.font = [UIFont systemFontOfSize:self.slidingMenuFontSize];
        // 开启手势事件
        slidingMenuLabel.userInteractionEnabled = YES;
        objc_setAssociatedObject(self, &key_slidingMenuLabel, slidingMenuLabel, OBJC_ASSOCIATION_RETAIN);
        return slidingMenuLabel;
    }
}

// 获取当前文本内容数据
- (NSArray *)slidingMenuTitles
{
    if (objc_getAssociatedObject(self, &key_slidingMenuTitles)) {
        return objc_getAssociatedObject(self, &key_slidingMenuTitles);
    } else {
        NSArray *slidingMenuTitles = [self.slidingMenuDelegate slidingMenuSectionIndexTitlesForTableView:self];
        objc_setAssociatedObject(self, &key_slidingMenuTitles, slidingMenuTitles, OBJC_ASSOCIATION_RETAIN);
        return slidingMenuTitles;
    }
}

// 设置文本颜色读写操作
- (void)setSlidingMenuTitleColor:(UIColor *)slidingMenuTitleColor
{
    if (self.slidingMenuTitleColor != slidingMenuTitleColor) {
        objc_setAssociatedObject(self, &slidingMenuTitleColor, slidingMenuTitleColor, OBJC_ASSOCIATION_RETAIN);
        // 设置文本的颜色
        self.slidingMenuLabel.textColor = slidingMenuTitleColor;
    }
}

- (UIColor *)slidingMenuTitleColor
{
    return objc_getAssociatedObject(self, &key_slidingMenuTitleColor);
}

// 设置视图背景颜色
- (void)setSlidingMenuBackgroudColor:(UIColor *)slidingMenuBackgroudColor
{
    if (self.slidingMenuBackgroudColor != slidingMenuBackgroudColor) {
        objc_setAssociatedObject(self, &key_slidingMenuBackgroudColor, slidingMenuBackgroudColor, OBJC_ASSOCIATION_RETAIN);
        // 设置文本的背景颜色
        self.slidingMenuLabel.backgroundColor = slidingMenuBackgroudColor;
    }
}

- (UIColor *)slidingMenuBackgroudColor
{
    return objc_getAssociatedObject(self, &key_slidingMenuBackgroudColor);
}

// 设置视图高亮背景颜色
- (void)setSlidingMenuHighlightBackgroudColor:(UIColor *)slidingMenuHighlightBackgroudColor
{
    if (self.slidingMenuHighlightBackgroudColor != slidingMenuHighlightBackgroudColor) {
        objc_setAssociatedObject(self, &key_slidingMenuHighlightBackgroudColor, slidingMenuHighlightBackgroudColor, OBJC_ASSOCIATION_RETAIN);
        // 设置文本的背景颜色
    }
}

- (UIColor *)slidingMenuHighlightBackgroudColor
{
    return objc_getAssociatedObject(self, &key_slidingMenuHighlightBackgroudColor);
}

// 设置类型
- (void)setSlidingMenutype:(SMSlidingMenuType)slidingMenutype
{
    if (self.slidingMenutype != slidingMenutype) {
        objc_setAssociatedObject(self, &key_slidingMenutype, @(slidingMenutype), OBJC_ASSOCIATION_ASSIGN);
        if (self.slidingMenutype == SMSlidingMenuTypeNone) {
            self.slidingMenuLabel.layer.cornerRadius = 0;
            self.slidingMenuLabel.layer.masksToBounds = NO;
        } else {
            self.slidingMenuLabel.layer.cornerRadius = kSMSlidingMenu_width / 2.0;
            self.slidingMenuLabel.layer.masksToBounds = YES;
        }
    }
}

- (SMSlidingMenuType )slidingMenutype
{
    return [objc_getAssociatedObject(self, &key_slidingMenutype) intValue];
}

// 设置字体大小
- (void)setSlidingMenuFontSize:(CGFloat)slidingMenuFontSize
{
    if (self.slidingMenuFontSize != slidingMenuFontSize) {
        objc_setAssociatedObject(self, &key_slidingMenuFontSize, @(slidingMenuFontSize), OBJC_ASSOCIATION_RETAIN);
        // 设置字体的大小
        self.slidingMenuLabel.font = [UIFont systemFontOfSize:slidingMenuFontSize];
    }
}

- (CGFloat )slidingMenuFontSize
{
    NSLog(@"%@",objc_getAssociatedObject(self, &key_slidingMenuFontSize));
    return [objc_getAssociatedObject(self, &key_slidingMenuFontSize) floatValue];
}

// 设置菜单视图的行间距
- (void)setSlidingMenuLineSpacing:(CGFloat)slidingMenuLineSpacing
{
    if (self.slidingMenuLineSpacing != slidingMenuLineSpacing) {
        objc_setAssociatedObject(self, &key_slidingMenuLineSpacing, @(slidingMenuLineSpacing), OBJC_ASSOCIATION_RETAIN);
        // 当前视图已经被加载了，就重新加载
        if (self.superview != nil && self.slidingMenuLabel.superview != nil) {
            [self displayMenuViewWithSuperView:self.superview];
        }
    }
}

- (CGFloat )slidingMenuLineSpacing
{
    return [objc_getAssociatedObject(self, &key_slidingMenuLineSpacing) floatValue];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    NSLog(@"superView:%@",self.superview);
    if (self.superview != nil) {
        // 当前视图被添加到父视图上
        [self displayMenuViewWithSuperView:self.superview];
    } else {
        // 当前视图被移除
        [self.slidingMenuLabel removeFromSuperview];
    }
}

#pragma mark - layoutSubviews
- (void)displayMenuViewWithSuperView:(UIView *)superView
{
    // 1.判断当前表视图是否使用了自定义右侧滑动菜单代理对象
    if ([self.slidingMenuDelegate respondsToSelector:@selector(slidingMenuSectionIndexTitlesForTableView:)] && self.slidingMenuTitles.count > 0) {
        // 02 设置字体大小的默认值
        if (self.slidingMenuFontSize == 0) {
            self.slidingMenuFontSize = 12;
        }
        // 03 设置高亮字体的默认背景颜色
        if (self.slidingMenuHighlightBackgroudColor == nil) {
            self.slidingMenuHighlightBackgroudColor = [UIColor colorWithWhite:.5 alpha:.7];
        }
        // 04 设置文本字体默认颜色
        if (self.slidingMenuTitleColor == nil) {
            self.slidingMenuTitleColor = [UIColor blueColor];
        }
        // 05 设置滑动文本视图默认背景颜色
        if (self.slidingMenuBackgroudColor == nil) {
            self.slidingMenuBackgroudColor = [UIColor colorWithWhite:.5 alpha:.5];
        }
        
        // 2.设置滑动视图文本
        // 显示文本的内容
        NSString *textString = [self.slidingMenuTitles componentsJoinedByString:@"\n"];
        // 转换成属性字符串
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:textString];
        // 设置行间距
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = self.slidingMenuLineSpacing;
        paragraphStyle.paragraphSpacing = 0;
        paragraphStyle.minimumLineHeight = self.slidingMenuFontSize;
        paragraphStyle.maximumLineHeight = self.slidingMenuFontSize;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textString length])];
        self.slidingMenuLabel.attributedText = attributedString;
        
        // 3.设置滑动视图大小
        self.slidingMenuLabel.frame = CGRectMake(self.frame.size.width - kSMSlidingMenu_right_margin - kSMSlidingMenu_width, kSMSlidingMenu_top_margin, kSMSlidingMenu_width, self.frame.size.height - kSMSlidingMenu_top_margin * 2);
        [superView addSubview:self.slidingMenuLabel];
    }
}

#pragma mark - 
#pragma mark - SMTableViewSlidingMenuDelegate
// 点击开始
- (void)sliderMenuLabelTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 01 设置高亮和开始
    self.slidingMenuLabel.backgroundColor = self.slidingMenuHighlightBackgroudColor;
    // 02 获取点击菜单内容的索引位置
    NSInteger touchIndex = [self sectionIndexWithTouches:touches];
    // 03 根据点击的索引位置设置当前视图滑动的索引位置
    [self scrollToSectionWithTouchIndex:touchIndex];
}

// 点击移动
- (void)sliderMenuLabelTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 01 设置高亮和开始
    self.slidingMenuLabel.backgroundColor = self.slidingMenuHighlightBackgroudColor;
    // 02 获取点击菜单内容的索引位置
    NSInteger touchIndex = [self sectionIndexWithTouches:touches];
    // 03 根据点击的索引位置设置当前视图滑动的索引位置
    [self scrollToSectionWithTouchIndex:touchIndex];
}

// 点击结束
- (void)sliderMenuLabelTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 01 取消高亮
    self.slidingMenuLabel.backgroundColor = self.slidingMenuBackgroudColor;
}

// 点击取消
- (void)sliderMenuLabelTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 01 取消高亮
    self.slidingMenuLabel.backgroundColor = self.slidingMenuBackgroudColor;
}

#pragma mark - 根基手指对象计算点击的菜单的索引位置以及自动设置滚动位置
/*
 *  根基手指对象判断所点击文本的索引位置
 */
- (NSInteger)sectionIndexWithTouches:(NSSet<UITouch *> *)touches
{
    if (self.slidingMenuTitles.count == 1) {
        // 当前只有一个滑动菜单选项
        return 0;
    } else {
        // 01 获取手指点击的纵坐标
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.slidingMenuLabel];
        CGFloat touch_y = touchPoint.y;
        // 02 获取第一个选项内容底部结束位置
        // 计算方式 = (视图总高度 － 文本总高度) ／ 2 ＋ 一行文本高度 ＋ 一般的行间距高度
        CGFloat firstMenu_bottom = (self.slidingMenuLabel.frame.size.height - (self.slidingMenuFontSize * self.slidingMenuTitles.count + self.slidingMenuLineSpacing * (self.slidingMenuTitles.count - 1))) / 2.0 + self.slidingMenuFontSize + self.slidingMenuLineSpacing / 2.0;
        // 03 获取最后选项内容顶部开始位置
        CGFloat lastMenu_top = self.slidingMenuLabel.frame.size.height - firstMenu_bottom;
        // 04 判断当前点击的位置
        if (touch_y <= firstMenu_bottom) {
            // 05 点击的是第一个菜单按钮的位置
            return 0;
        } else if (touch_y >= lastMenu_top) {
            // 06 点击的是最后一个菜单按钮的位置
            return self.slidingMenuTitles.count - 1;
        } else {
            // 07 点击的是区间按钮的位置
            // 获取超出第一个菜单按钮底部的高度
            int exceedHeight = touch_y - firstMenu_bottom;
            int exceedIndex = exceedHeight / (self.slidingMenuFontSize + self.slidingMenuLineSpacing);
            return exceedIndex + 1;
        }
    }
}

/*
 *  根据点击的索引位置设置当前视图滑动的索引位置
 */
- (void)scrollToSectionWithTouchIndex:(NSInteger)touchIndex
{
    // 当前是否实现了滑动协议
    if ([self.slidingMenuDelegate respondsToSelector:@selector(tableView:slidingMenuSectionForSectionIndexTitle:atIndex:)]) {
        // 01 如果实现了协议方法
        NSInteger setIndex = [self.slidingMenuDelegate tableView:self slidingMenuSectionForSectionIndexTitle:self.slidingMenuTitles[touchIndex] atIndex:touchIndex];
        // 区间兼容
        setIndex = MIN(self.numberOfSections - 1, setIndex);
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:setIndex] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        // 02 如果没有实现协议方法设置点击文本索引的组位置
        // 区间兼容
        touchIndex = MIN(self.numberOfSections - 1, touchIndex);
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:touchIndex] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

@end
