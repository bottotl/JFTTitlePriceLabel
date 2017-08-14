//
//  JFTRDDTitlePriceLabel.m
//  RichTextDemo
//
//  Created by 於林涛 on 2017/5/8.
//  Copyright © 2017年 jft0m. All rights reserved.
//

#import "JFTTitlePriceLabel.h"
#import <CoreText/CoreText.h>

static NSUInteger const numberOfLines = 2;
static CGFloat const JFT_TITLE_PRICE_HEIGHT = 1000;

@interface JFTTitlePriceLabel ()
@property (nonatomic, strong) NSAttributedString *titleAttributedText;
@property (nonatomic, strong) NSMutableAttributedString *internalCustomString;
@end

@implementation JFTTitlePriceLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [JFTTitlePriceLabel LabelWithText:self.attributedText price:self.priceText andWidth:size.width numberOfLines:nil];
    return CGSizeMake(size.width, height);
}

- (void)drawRect:(CGRect)rect {
    self.internalCustomString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [self.internalCustomString appendAttributedString:[self makePriceAttributedText:self.priceText]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -JFT_TITLE_PRICE_HEIGHT);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.internalCustomString);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, JFT_TITLE_PRICE_HEIGHT), NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)self.internalCustomString)), path, NULL);
    CGPathRelease(path);
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint *origins = malloc(sizeof(CGPoint) * CFArrayGetCount(lines));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, CFArrayGetCount(lines)), origins);
    
    for (int i = 0; i < MIN(CFArrayGetCount(lines), numberOfLines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGPoint point = origins[i];
        if (i == numberOfLines - 1 && CFArrayGetCount(lines) > numberOfLines) { /// 最后一行 并且展示不下
            [self drawLastLine:line width:rect.size.width inContext:context origin:point];
        } else {
            CGContextSetTextPosition(context, point.x , point.y);
            CTLineDraw(line, context);
        }
    }
    
    free(origins);
    CFRelease(frame);
    CGContextRestoreGState(context);
}

- (void)drawLastLine:(CTLineRef)line width:(CGFloat)width inContext:(CGContextRef)context origin:(CGPoint)point {
    CFRange textRange = CTLineGetStringRange(line);
    NSMutableAttributedString *lineAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self.attributedText attributedSubstringFromRange:NSMakeRange(textRange.location, (self.attributedText.length - textRange.location))]];
    NSDictionary *tokenAttributes = [self.attributedText attributesAtIndex:self.attributedText.length - 1
                                                            effectiveRange:NULL];
    NSAttributedString *tokenAttributedString = [self makePriceTruncationAttributedText:self.priceText tokenAttributes:tokenAttributes];
    [lineAttributedString appendAttributedString:tokenAttributedString];
    CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenAttributedString);
    CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)lineAttributedString);
    CTLineTruncationType truncationType = kCTLineTruncationEnd;
    CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, width, truncationType, truncationToken);
    CGContextSetTextPosition(context, point.x , point.y);
    CTLineDraw(truncatedLine, context);
}

- (NSAttributedString * _Nonnull)makePriceTruncationAttributedText:(NSString *)price tokenAttributes:(NSDictionary *)attributes {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"\u2026\u2060 " attributes:attributes];
    [attr appendAttributedString:[self makePriceAttributedText:price]];
    return attr;
}

- (NSAttributedString * _Nonnull)makePriceAttributedText:(NSString *)price {
    NSDictionary *priceDic = @{NSFontAttributeName : [UIFont systemFontOfSize:14.f],
                               NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.8]};
    return [[NSAttributedString alloc] initWithString:[self makePriceString:price] attributes:priceDic];
}

- (NSString * _Nonnull)makePriceString:(NSString *)price {
    if (!price.length) return @"";
    NSString *priceString = [NSString stringWithFormat:@" %@",price];
    NSMutableString *newPriceString = [[NSMutableString alloc] init];
    for (int i = 0; i < priceString.length; i++) {
        [newPriceString appendString:[priceString substringWithRange:NSMakeRange(i, 1)]];
        if (i < priceString.length) {
            [newPriceString appendString:@"\u2060"];
        }
    }
    return newPriceString.copy;
}

+ (CGFloat)LabelWithText:(NSAttributedString *)attributedText price:(NSString *)priceText andWidth:(CGFloat)width numberOfLines:(NSInteger *)numLines {
    if (!attributedText.length) return 1.f;
    
    JFTTitlePriceLabel *label = [JFTTitlePriceLabel new];
    NSMutableAttributedString *realAttri = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [realAttri appendAttributedString:[label makePriceAttributedText:priceText]];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)realAttri);

    CGRect drawingRect = CGRectMake(0, 0, width, JFT_TITLE_PRICE_HEIGHT);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)realAttri)), path, NULL);
    CGPathRelease(path);
    CFRelease(frameSetter);
    
    CFArrayRef ctLines = CTFrameGetLines(textFrame);
    CGPoint *origins = malloc(sizeof(CGPoint) * CFArrayGetCount(ctLines));
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, CFArrayGetCount(ctLines)), origins);
    CGFloat descent;
    NSInteger lineCount = MIN(CFArrayGetCount(ctLines), numberOfLines);
    CTLineRef line = CFArrayGetValueAtIndex(ctLines, lineCount - 1);
    CTLineGetTypographicBounds(line, nil, &descent, nil);
    CGFloat lastLinePointY = origins[lineCount - 1].y - descent;
    
    CFRelease(textFrame);
    free(origins);
    if (numLines) *numLines = lineCount;
    return ceil(JFT_TITLE_PRICE_HEIGHT - lastLinePointY) + 1;
}

@end
