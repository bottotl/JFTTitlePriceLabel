//
//  ViewController.m
//  JFTEndNoTrun
//
//  Created by jft0m on 2017/8/14.
//  Copyright © 2017年 jft0m. All rights reserved.
//

#import "ViewController.h"
#import "JFTTitlePriceLabel.h"

@interface ViewController ()
@property (nonatomic, strong) JFTTitlePriceLabel *priceLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.priceLabel = [[JFTTitlePriceLabel alloc] initWithFrame:CGRectMake(50, 100, 300, 300)];
    [self.view addSubview:self.priceLabel];
    self.priceLabel.backgroundColor = [UIColor blackColor];
    self.priceLabel.attributedText = [[NSAttributedString alloc] initWithString:@"标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.priceLabel.priceText = @"￥888";
    [self.priceLabel sizeToFit];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
