//
//  ViewController.m
//  NetEastControl
//
//  Created by Bourbon on 16/4/23.
//  Copyright © 2016年 Bourbon. All rights reserved.
//

#import "ViewController.h"
#import "NetEasySlider.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NetEasySlider *slider = [[NetEasySlider alloc] initWithFrame:self.view.frame];
    slider.minValue = 0;
    slider.maxValue = 100;
    slider.center = self.view.center;
    [slider addTarget:self action:@selector(value:) forControlEvents:(UIControlEventValueChanged)];
    [self.view addSubview:slider];
    
    self.view.backgroundColor = [UIColor lightGrayColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)value:(NetEasySlider *)slider
{
    NSLog(@"%f",slider.currentValue);
}


@end
