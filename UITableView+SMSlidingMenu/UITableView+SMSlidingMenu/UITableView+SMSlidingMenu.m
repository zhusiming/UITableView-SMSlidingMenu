//
//  UITableView+SMSlidingMenu.m
//  UITableView+SMSlidingMenu
//
//  Created by 朱思明 on 16/9/5.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import "UITableView+SMSlidingMenu.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>


#define kSMLabel_DrawImageName @"kSMLabel_DrawImageName"


#pragma mark -
#pragma mark - 文本自类化定义和实现
@interface SliderMenuItem()

/*
 *  数据类型 default:SliderMenuItemTypeText
 */
@property (nonatomic, assign) SliderMenuItemType itemType;
/*
 *  内容
 *  如果itemType ＝ SliderMenuItemTypeText 当前数据是文本数据
 *  如果itemType ＝ SliderMenuItemTypeImage 当前数据是图片的名字
 */
@property (nonatomic, strong) NSString * _Nullable content;

@end


@implementation SliderMenuItem

/*
 *  创建一个图片类型数据
 */
+ (SliderMenuItem * __nonnull)typeImageWithImageName:(NSString * __nonnull)content
{
    SliderMenuItem *menuItem = [[self alloc] init];
    menuItem.itemType = SliderMenuItemTypeImage;
    menuItem.content = content;
    return menuItem;
}

/*
 *  创建一个文本类型数据
 */
+ (SliderMenuItem * __nonnull)typeTextWithTitle:(NSString * __nonnull)content;
{
    SliderMenuItem *menuItem = [[self alloc] init];
    menuItem.itemType = SliderMenuItemTypeText;
    menuItem.content = content;
    return menuItem;
}

@end


#pragma mark -
#pragma mark - 文本事件协议方法
@protocol SliderMenuTouchViewDelegate <NSObject>
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
#pragma mark - 视图点击类定义和实现
@interface SliderMenuTouchView: UIView
/*
 *  代理对象
 */
@property (nonatomic, weak) id<SliderMenuTouchViewDelegate> _Nullable delegate;
@end

@implementation SliderMenuTouchView

// 重写初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
        pan.cancelsTouchesInView = NO;
        [self addGestureRecognizer:pan];
    }
    return self;
}

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
#pragma mark - 文本自类化定义和实现
@interface SliderMenuLabel: UILabel

// 属性字符串
@property (nonatomic, strong) NSMutableAttributedString *attrString;
// 内容的高度
@property (nonatomic, assign) float textHeight;

@end


@implementation SliderMenuLabel

// 重写setter方法
- (void)setAttrString:(NSMutableAttributedString *)attrString
{
    _attrString = attrString;
    [self setNeedsDisplay];
}

// 绘制
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // 数据容错判断
    if (_attrString == nil) {
        return;
    }
    //    self.backgroundColor = [UIColor orangeColor];
    
    // 步骤1：得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
    // 因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 步骤2：翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角为（0，0））
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 步骤3：创建NSAttributedString
    // 配置绘制对象
    // 设置颜色
    [_attrString addAttribute:(id)kCTForegroundColorAttributeName value:(id)self.textColor range:NSMakeRange(0, _attrString.length)];
    //字体样式 ,把helveticaBold 样式加到整个，string上
    [_attrString addAttribute:(id)kCTFontAttributeName value:self.font range:NSMakeRange(0, _attrString.length)];
    
    // 步骤4：根据NSAttributedString创建CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attrString);
    
    // 步骤5：创建绘制区域CGPathRef
    CGFloat draw_y = (self.frame.size.height - self.textHeight) / 2.0 ;
    CGRect bouds = CGRectInset(self.frame, 0.0f, draw_y);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bouds);
    
    // 步骤6：根据CTFramesetterRef和CGPathRef创建CTFrame；
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attrString length]), path, NULL);
    CGContextAddPath(context, path);
    // 步骤7：CTFrameDraw绘制
    CTFrameDraw(frame,context);
    
    //---------------------------绘制图片---------------------------
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    //NSLog(@"line count = %ld",CFArrayGetCount(lines));
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        //NSLog(@"ascent = %f,descent = %f,leading = %f",lineAscent,lineDescent,lineLeading);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        //NSLog(@"run count = %ld",CFArrayGetCount(runs));
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            NSString *imageName = [attributes objectForKey:kSMLabel_DrawImageName];
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                //图片渲染逻辑
                if (image) {
                    CGRect imageDrawRect;
                    //                    imageDrawRect.size = CGSizeMake(self.font.pointSize , self.font.pointSize );
                    imageDrawRect.size = CGSizeMake(image.size.width , image.size.height );
                    imageDrawRect.origin.x = (self.frame.size.width - image.size.width) / 2.0;
                    //                    CGFloat draw_y = (self.frame.size.height - self.textHeight) / 2.0;
                    imageDrawRect.origin.y = runRect.origin.y + draw_y - image.size.height * 0.2;
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                }
            }
        }
    }
    
    //释放对象
    CGPathRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
}

@end


#pragma mark -
#pragma mark - 表视图类延展和声明
@interface UITableView ()<SliderMenuTouchViewDelegate>

/*
 *  滑动事件视图
 */
@property (nonatomic, strong, readonly) SliderMenuTouchView *sliderMenuTouchView;

/*
 *  菜单文本视图
 */
@property (nonatomic, strong, readonly) SliderMenuLabel *slidingMenuLabel;

/*
 *  滑动文本视图内容
 */
@property (nonatomic, strong) NSArray<SliderMenuItem *> *slidingMenuTitles;

@end

#pragma mark -
#pragma mark - 表视图类目实现

@implementation UITableView (SMSlidingMenu)

// 定义属性的键值
const void *key_slidingMenuDelegate;                    // 代理对象
const void *key_sliderMenuTouchView;                    // 菜单事件视图
const void *key_slidingMenuLabel;                       // 菜单文本视图
const void *key_slidingMenuTitleColor;                  // 菜单文本颜色
const void *key_slidingMenuBackgroudColor;              // 菜单文本视图背景颜色
const void *key_slidingMenuHighlightBackgroudColor;     // 菜单文本视图高亮背景颜色
const void *key_slidingMenutype;                        // 菜单文本视图样式
const void *key_slidingMenuFontSize;                    // 菜单文本字体大小
const void *key_slidingMenuLineSpacing;                 // 菜单文本间距
const void *key_slidingMenuTitles;                      // 菜单文本数据
const void *key_slidingMenuAutoShow;                    // 菜单文本自动显示设置

#pragma mark - setter/getter
// 设置代理读写操作
- (void)setSlidingMenuDelegate:(id<SMTableViewSlidingMenuDelegate>)slidingMenuDelegate
{
    if (self.slidingMenuDelegate != slidingMenuDelegate) {
        objc_setAssociatedObject(self, &key_slidingMenuDelegate, slidingMenuDelegate, OBJC_ASSOCIATION_ASSIGN);
        // 01 设置方法交换
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Method reloadData = class_getInstanceMethod([self class], @selector(reloadData));
            Method rewriteReloadData = class_getInstanceMethod([self class], @selector(rewriteReloadData));
            method_exchangeImplementations(reloadData, rewriteReloadData);
        });
    }
}

- (id<SMTableViewSlidingMenuDelegate>)slidingMenuDelegate
{
    return objc_getAssociatedObject(self, &key_slidingMenuDelegate);
}

// 获取菜单事件视图
- (SliderMenuTouchView *)sliderMenuTouchView
{
    if (objc_getAssociatedObject(self, &key_sliderMenuTouchView)) {
        return objc_getAssociatedObject(self, &key_sliderMenuTouchView);
    } else {
        SliderMenuTouchView *sliderMenuTouchView = [[SliderMenuTouchView alloc] initWithFrame:CGRectZero];
        sliderMenuTouchView.backgroundColor = [UIColor clearColor];
        sliderMenuTouchView.delegate = self;
        // 把菜单文本视图添加到点击事件视图上
        [sliderMenuTouchView addSubview:self.slidingMenuLabel];
        objc_setAssociatedObject(self, &key_sliderMenuTouchView, sliderMenuTouchView, OBJC_ASSOCIATION_RETAIN);
        return sliderMenuTouchView;
    }
}

// 获取菜单文本视图
- (SliderMenuLabel *)slidingMenuLabel
{
    if (objc_getAssociatedObject(self, &key_slidingMenuLabel)) {
        return objc_getAssociatedObject(self, &key_slidingMenuLabel);
    } else {
        SliderMenuLabel *slidingMenuLabel = [[SliderMenuLabel alloc] initWithFrame:CGRectZero];
        slidingMenuLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        slidingMenuLabel.numberOfLines = 0;
        slidingMenuLabel.font = [UIFont boldSystemFontOfSize:self.slidingMenuFontSize];
        // 开启手势事件
        slidingMenuLabel.userInteractionEnabled = NO;
        objc_setAssociatedObject(self, &key_slidingMenuLabel, slidingMenuLabel, OBJC_ASSOCIATION_RETAIN);
        return slidingMenuLabel;
    }
}

// 获取当前文本内容数据
- (NSArray<SliderMenuItem *> *)slidingMenuTitles
{
    if ([self.slidingMenuDelegate respondsToSelector:@selector(slidingMenuSectionIndexTitlesForTableView:)]) {
        return [self.slidingMenuDelegate slidingMenuSectionIndexTitlesForTableView:self];
    } else {
        return nil;
    }
}

// 设置文本颜色读写操作
- (void)setSlidingMenuTitleColor:(UIColor *)slidingMenuTitleColor
{
    if (self.slidingMenuTitleColor != slidingMenuTitleColor) {
        objc_setAssociatedObject(self, &key_slidingMenuTitleColor, slidingMenuTitleColor, OBJC_ASSOCIATION_RETAIN);
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
        self.slidingMenuLabel.font = [UIFont boldSystemFontOfSize:slidingMenuFontSize];
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
        if (self.superview != nil && self.sliderMenuTouchView.superview != nil) {
            [self displayMenuViewWithSuperView:self.superview];
        }
    }
}

- (CGFloat )slidingMenuLineSpacing
{
    return [objc_getAssociatedObject(self, &key_slidingMenuLineSpacing) floatValue];
}

#pragma mark - 设置视图自动显示效果
// 获取显示状态
- (BOOL)slidingMenuAutoShow
{
    return [objc_getAssociatedObject(self, &key_slidingMenuAutoShow) boolValue];
}

// 菜单文本自动显示设置
- (void)setSlidingMenuAutoShow:(BOOL)slidingMenuAutoShow
{
    if (self.slidingMenuAutoShow != slidingMenuAutoShow) {
        objc_setAssociatedObject(self, &key_slidingMenuAutoShow, @(slidingMenuAutoShow), OBJC_ASSOCIATION_ASSIGN);
        if (slidingMenuAutoShow == YES) {
            self.sliderMenuTouchView.alpha = 0;
            // 设置监听操作
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                // 重写点击开始方法
                Method touchesBegan = class_getInstanceMethod([self class], @selector(touchesBegan:withEvent:));
                Method overrideTouchesBegan = class_getInstanceMethod([self class], @selector(overrideTouchesBegan:withEvent:));
                method_exchangeImplementations(touchesBegan, overrideTouchesBegan);
                // 重写点击滑动方法
                Method touchesMoved = class_getInstanceMethod([self class], @selector(touchesMoved:withEvent:));
                Method overrideTouchesMoved = class_getInstanceMethod([self class], @selector(overrideTouchesMoved:withEvent:));
                method_exchangeImplementations(touchesMoved, overrideTouchesMoved);
                // 重写点击结束方法
                Method touchesEnded = class_getInstanceMethod([self class], @selector(touchesEnded:withEvent:));
                Method overrideTouchesEnded = class_getInstanceMethod([self class], @selector(overrideTouchesEnded:withEvent:));
                method_exchangeImplementations(touchesEnded, overrideTouchesEnded);
                // 重写点击被打断方法
                Method touchesCancelled = class_getInstanceMethod([self class], @selector(touchesCancelled:withEvent:));
                Method overrideTouchesCancelled = class_getInstanceMethod([self class], @selector(overrideTouchesCancelled:withEvent:));
                method_exchangeImplementations(touchesCancelled, overrideTouchesCancelled);
                
                self.panGestureRecognizer.cancelsTouchesInView = NO;
            });
        } else {
            self.sliderMenuTouchView.alpha = 1;
        }
    }
    
}

// 重写点击开始
- (void)overrideTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 调用系统的点击事件
    [self overrideTouchesBegan:touches withEvent:event];
    
    // 执行自动显示效果
    [self showSliderMenuTouchView];
    
}

// 重写点击滑动方法
- (void)overrideTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 调用系统的滑动事件
    [self overrideTouchesMoved:touches withEvent:event];
    
    if (self.sliderMenuTouchView.superview == nil) {
        // 执行自动显示效果
        [self showSliderMenuTouchView];
    }
}

// 重写点击结束
- (void)overrideTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 调用系统的点击事件
    [self overrideTouchesEnded:touches withEvent:event];
    
    // 执行自动隐藏效果
    [self hiddenSliderMenuTouchViewWithafterDelay:kSMSlidingMenu_autoShowAfterDelay];
}

// 重写点击取消
- (void)overrideTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 调用系统的点击事件
    [self overrideTouchesCancelled:touches withEvent:event];
    // 执行自动隐藏效果
    [self hiddenSliderMenuTouchViewWithafterDelay:kSMSlidingMenu_autoShowAfterDelay];
}

// 延迟隐藏右侧菜单视图
- (void)hiddenSliderMenuTouchViewWithafterDelay:(NSTimeInterval)afterDelay
{
    // 当前时开启自动隐藏和显示模式
    if (self.slidingMenuAutoShow == YES) {
        [self performSelector:@selector(hiddenSliderMenuTouchView) withObject:nil afterDelay:afterDelay];
    }
}

// 隐藏滑动菜单视图
- (void)hiddenSliderMenuTouchView
{
    // 当前时开启自动隐藏和显示模式
    if (self.slidingMenuAutoShow == YES) {
        [UIView animateWithDuration:.2 animations:^{
            // 隐藏视图视图
            self.sliderMenuTouchView.alpha = 0;
        }];
    }
}

// 显示滑动菜单视图
- (void)showSliderMenuTouchView
{
    // 当前时开启自动隐藏和显示模式
    if (self.slidingMenuAutoShow == YES) {
        // 取消隐藏延迟事件
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenSliderMenuTouchView) object:nil];
        // 执行显示效果
        [UIView animateWithDuration:.2 animations:^{
            // 隐藏视图视图
            self.sliderMenuTouchView.alpha = 1;
        }];
    }
}

#pragma mark - 监听视图是否从父视图上移除
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    NSLog(@"superView:%@",self.superview);
    if (self.superview != nil) {
        // 当前视图被添加到父视图上
        [self displayMenuViewWithSuperView:self.superview];
    } else {
        // 当前视图被移除
        [self.sliderMenuTouchView removeFromSuperview];
    }
}

#pragma mark - CTRunDelegate delegate
void RunDelegateDeallocCallback(void *refCon) {
    
}

//设置空白区域的高度
CGFloat RunDelegateGetAscentCallback(void *refCon) {
    //NSString *imageName = (__bridge NSString *)refCon;
    return 0;//[UIImage imageNamed:imageName].size.height / 4;
}

CGFloat RunDelegateGetDescentCallback(void *refCon) {
    return 0;
}

//设置空白区域的宽度
CGFloat RunDelegateGetWidthCallback(void *refCon){
    NSString *imageName = (__bridge NSString *)refCon;
    UIImage *image = [UIImage imageNamed:imageName];
    return image.size.width;
}

#pragma mark - layoutSubviews
// 刷新
- (void)rewriteReloadData
{
    [self rewriteReloadData];
    if (self.superview != nil) {
        // 当前视图被添加到父视图上
        [self displayMenuViewWithSuperView:self.superview];
    } else {
        // 当前视图被移除
        [self.sliderMenuTouchView removeFromSuperview];
    }
}

- (void)displayMenuViewWithSuperView:(UIView *)superView
{
    // 1.判断当前表视图是否使用了自定义右侧滑动菜单代理对象
    if ([self.slidingMenuDelegate respondsToSelector:@selector(slidingMenuSectionIndexTitlesForTableView:)] && self.slidingMenuTitles.count > 0) {
        
        // 02 设置字体大小的默认值
        if (self.slidingMenuFontSize == 0) {
            self.slidingMenuFontSize = 10;
        }
        // 02 设置字体默认间距
        if (self.slidingMenuLineSpacing == 0) {
            self.slidingMenuLineSpacing = 2;
        }
        
        // 03 设置高亮字体的默认背景颜色
        if (self.slidingMenuHighlightBackgroudColor == nil) {
            self.slidingMenuHighlightBackgroudColor = [UIColor colorWithWhite:.5 alpha:.7];
        }
        // 04 设置文本字体默认颜色
        if (self.slidingMenuTitleColor == nil) {
            self.slidingMenuTitleColor = [UIColor grayColor];
        }
        // 05 设置滑动文本视图默认背景颜色
        if (self.slidingMenuBackgroudColor == nil) {
            self.slidingMenuBackgroudColor = [UIColor colorWithWhite:.5 alpha:.5];
        }
        
        // 2.设置滑动视图文本
        // 为图片设置CTRunDelegate,delegate决定留给图片的空间大小
        CTRunDelegateCallbacks imageCallbacks;
        imageCallbacks.version = kCTRunDelegateVersion1;
        imageCallbacks.dealloc = RunDelegateDeallocCallback;
        imageCallbacks.getAscent = RunDelegateGetAscentCallback;
        imageCallbacks.getDescent = RunDelegateGetDescentCallback;
        imageCallbacks.getWidth = RunDelegateGetWidthCallback;
        // 做图片过滤处理
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] init];
        for (int i = 0; i < self.slidingMenuTitles.count; i++) {
            // 获取当前数组信息
            SliderMenuItem *item = self.slidingMenuTitles[i];
            if (item.itemType == SliderMenuItemTypeImage) {
                // 把图片对象转换成
                CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, NULL);
                NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
                [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
                CFRelease(runDelegate);
                //设置空格的属性
                [imageAttributedString addAttribute:kSMLabel_DrawImageName value:item.content range:NSMakeRange(0, 1)];
                // 把当前的图片的属性代替文本添加到属性字符串中
                [attributedString appendAttributedString:imageAttributedString];
            } else {
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:item.content]];
            }
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\r"]];
        }
        // 设置行间距
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = self.slidingMenuLineSpacing;
        paragraphStyle.paragraphSpacing = 0.0f;//段与段之间的间距
        paragraphStyle.paragraphSpacingBefore = 0.0f;//段首行空白空
        paragraphStyle.headIndent = 0;//整体缩进(首行除外)
        paragraphStyle.tailIndent = 0;//
#warning ios bug
        //        paragraphStyle.lineHeightMultiple = self.slidingMenuFontSize;
        paragraphStyle.minimumLineHeight = self.slidingMenuFontSize;
        paragraphStyle.maximumLineHeight = self.slidingMenuFontSize;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
        // 设置内容文本的高度
        self.slidingMenuLabel.textHeight = self.slidingMenuFontSize * self.slidingMenuTitles.count + self.slidingMenuLineSpacing * (self.slidingMenuTitles.count - 1);
        self.slidingMenuLabel.attrString = attributedString;
        
        // 3.设置点击事件视图大小
        self.sliderMenuTouchView.frame = CGRectMake(self.frame.origin.x + (self.frame.size.width - kSMSlidingMenu_right_margin - kSMSlidingMenu_width), self.frame.origin.y + kSMSlidingMenu_top_margin, kSMSlidingMenu_width + kSMSlidingMenu_right_margin, self.frame.size.height - kSMSlidingMenu_top_margin - kSMSlidingMenu_bottom_margin);
        // 3.设置滑动视图大小
        self.slidingMenuLabel.frame = CGRectMake(0, 0, kSMSlidingMenu_width, self.sliderMenuTouchView.frame.size.height);
        [superView addSubview:self.sliderMenuTouchView];
    }
}


#pragma mark -
#pragma mark - SliderMenuTouchViewDelegate
// 点击开始
- (void)sliderMenuLabelTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 01 设置高亮和开始
    self.slidingMenuLabel.backgroundColor = self.slidingMenuHighlightBackgroudColor;
    // 02 获取点击菜单内容的索引位置
    NSInteger touchIndex = [self sectionIndexWithTouches:touches];
    // 03 根据点击的索引位置设置当前视图滑动的索引位置
    [self scrollToSectionWithTouchIndex:touchIndex];
    // 04 执行自动显示效果
    [self showSliderMenuTouchView];
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
    // 02 执行自动隐藏效果
    [self hiddenSliderMenuTouchViewWithafterDelay:kSMSlidingMenu_autoShowAfterDelay];
}

// 点击取消
- (void)sliderMenuLabelTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 01 取消高亮
    self.slidingMenuLabel.backgroundColor = self.slidingMenuBackgroudColor;
    // 02 执行自动隐藏效果
    [self hiddenSliderMenuTouchViewWithafterDelay:kSMSlidingMenu_autoShowAfterDelay];
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
        CGPoint touchPoint = [touch locationInView:self.sliderMenuTouchView];
        CGFloat touch_y = touchPoint.y;
        // 02 获取第一个选项内容底部结束位置
        // 计算方式 = (视图总高度 － 文本总高度) ／ 2 ＋ 一行文本高度 ＋ 一般的行间距高度
        CGFloat firstMenu_bottom = (self.sliderMenuTouchView.frame.size.height - (self.slidingMenuFontSize * self.slidingMenuTitles.count + self.slidingMenuLineSpacing * (self.slidingMenuTitles.count - 1))) / 2.0 + self.slidingMenuFontSize + self.slidingMenuLineSpacing / 2.0;
        // 03 获取最后选项内容顶部开始位置
        CGFloat lastMenu_top = self.sliderMenuTouchView.frame.size.height - firstMenu_bottom;
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
    if ([self.slidingMenuDelegate respondsToSelector:@selector(tableView:slidingMenuSectionForSectionIndexItem:atIndex:)]) {
        // 01 如果实现了协议方法
        NSInteger setIndex = [self.slidingMenuDelegate tableView:self slidingMenuSectionForSectionIndexItem:self.slidingMenuTitles[touchIndex] atIndex:touchIndex];
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
