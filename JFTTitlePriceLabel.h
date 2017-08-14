//
//  JFTRDDTitlePriceLabel.h
//  RichTextDemo
//
//  Created by 於林涛 on 2017/5/8.
//  Copyright © 2017年 jft0m. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFTTitlePriceLabel : UIView

@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, copy) NSString *priceText;

+ (CGFloat)LabelWithText:(NSAttributedString *)attributedText price:(NSString *)priceText andWidth:(CGFloat)width numberOfLines:(NSInteger *)numLines;

@end
