# NetEastControl
一个模仿网易云音乐的控件
这些天一直在用网易云音乐，看到一个功能是可以更改音效，觉得这样的控制器蛮有意思的，决定模仿一下。先看下原图
![原图](http://www.bourbonz.cn/wp-content/uploads/2016/04/原图.gif)
这个圆形的slider就是要模仿的东西，这里不是通过继承自UISlider来实现，而是通过继承自UIControl，本来UISlider也是UIControl的子类，用法跟UISlider是一样的，我下载了网易云音乐的安装包，从里面找来了相应的图片，我在创建界面的时候大概逻辑这样的：
>1.最下面的中间圆形的类似按钮
2.圆形那妞外面的加减号和一圈灰色弧形
3.中间红色的指针
4.红色进度条

下面先看写最后的效果图
![效果图](http://www.bourbonz.cn/wp-content/uploads/2016/04/效果.gif)
(我的控制器的角度范围值是在0到PI中间，实在是找不准他的最小值和最大值的多少度，索性就拿0到PI来做了 O(∩_∩)O哈哈~)
现在开始创建:
新建一个UIControl的子类NetEasySlider
```
//
//  NetEasySlider.h
//  CoreEffect
//
//  Created by ZhengWei on 16/4/22.
//  Copyright © 2016年 Bourbon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetEasySlider : UIControl

@property (nonatomic,assign) CGFloat currentValue;
@property (nonatomic,assign) CGFloat minValue;
@property (nonatomic,assign) CGFloat maxValue;

@end

```
在实现文件里面添加如下宏和变量以便后续使用
```
#define kTroughImage [UIImage imageNamed:@"cm2_efc_knob_trough_prs"]    //中心圆形
#define kNeedleImage [UIImage imageNamed:@"cm2_efc_knob_needle_prs"]    //中间指针
#define kScaleImage  [UIImage imageNamed:@"cm2_efc_knob_scale"]         //中间灰色进度条

@interface NetEasySlider ()
{
    UIImageView *needleView;
    //半径
    CGFloat radius;
    //当前角度
    CGFloat angle;
}
@end
```
由于我们的内容有些是通过CGContextRef进行绘制的，然而UIKit和CoreGraphics的坐标是不同的(一个是左上角是原点一个是左下角是原点)
所以在初始化得时候还要多进行一步操作技师旋转坐标系
```
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        needleView = [[UIImageView alloc] initWithImage:kNeedleImage];
        needleView.bounds = CGRectMake(0, 0, kNeedleImage.size.width, kNeedleImage.size.height);
        needleView.center = self.center;
        [self addSubview:needleView];
        
        radius = kScaleImage.size.width/2-1;
        angle = M_PI;
        
        self.backgroundColor = [UIColor clearColor];
        //旋转坐标系
        self.transform = CGAffineTransformMakeScale(1, -1);
    }
    return self;
}
```


我这里的红色进度条是根据角度在drawRect:方法中实时绘制的,中间红色指针则根据角度来实时进行一个旋转,考虑到剩下两个背景是图片的关系，如果通过addSubView:的方式进行添加的话,会覆盖红色进度条.
所以这里也是将这两个背景在drawRect:方法中绘制出来.

由于随着多次调用drawRect:方法，图片这样的每次绘制会导致性能下降，这个我们下次再说.
那么在drawRect:方法中，我们需要做的事情有这么几点
>1.绘制背景图片
2.画进度条
3.中间红色指针根据当前角度尽心旋转

```
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //绘制背景图片
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextDrawImage(ref, CGRectMake((self.frame.size.width-kScaleImage.size.width)/2.0, (self.frame.size.height-kScaleImage.size.height)/2.0, kScaleImage.size.width, kScaleImage.size.height), kScaleImage.CGImage);
    CGContextDrawImage(ref, CGRectMake((self.frame.size.width-kTroughImage.size.height)/2.0, (self.frame.size.height-kTroughImage.size.width)/2.0, kTroughImage.size.width, kTroughImage.size.height), kTroughImage.CGImage);
    //绘制红色进度条
    CGContextAddArc(ref, self.center.x, self.center.y, radius, M_PI, angle, YES);
    CGContextSetLineWidth(ref, 2);
    CGContextSetStrokeColorWithColor(ref, [UIColor redColor].CGColor);
    CGContextStrokePath(ref);
    //指针根据角度进行旋转
    needleView.transform = CGAffineTransformMakeRotation(angle+M_PI_2);

}
```
我们这里采用了target-action方式，所以需要重写UIControl的两个方法
在第一个方法中我们进行开始的操作
```
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    return [super beginTrackingWithTouch:touch withEvent:event];
}
```
在第二个方法中，我们进行当前点的选择，然后根据当前的点来获取旋转角度，进而再绘制进度条和旋转红色指针,同时进行方法的触发，实现父视图的方法调用
```
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint point = [touch locationInView:self];
    CGFloat change  = atan2f(point.y-self.center.y, point.x-self.center.x);
    if (change >= 0) {
        angle = change;
        self.currentValue = (self.maxValue - self.minValue)*(angle+M_PI)/M_PI;
        //相应valueChanged的事件
        [self sendActionsForControlEvents:(UIControlEventValueChanged)];
    }
    [self setNeedsDisplay];
    return YES;
}
```
这样一个模仿网易云音乐的控件基本完成了
[点我下载代码]()

欢迎再评论中进行批评指正，我会第一时间进行回复的，谢谢
