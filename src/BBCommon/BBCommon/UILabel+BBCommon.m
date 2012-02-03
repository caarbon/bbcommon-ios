//
//  Created by Lee Fastenau on 8/3/11.
//  Copyright 2011 BigBig Bomb, LLC. All rights reserved.
//
#import "UILabel+BBCommon.h"
#import "UIView+BBCommon.h"

@implementation UILabel(BBCommon)

+ (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font frame:(CGRect)frame lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment {
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.text = text;
    label.font = font;
    label.lineBreakMode = lineBreakMode;
    label.textAlignment = alignment;
        
    // resize
    if (frame.size.width == 0 || frame.size.height == 0) {
        if (frame.size.width == 0) {
            label.numberOfLines = 1;
        } else {
            // todo: Assumes wrapping on width provided - don't do this
            label.numberOfLines = 0;
        }
        [label sizeToFit];
        BBResizeFrame(label, frame.size.width == 0 ? BBW(label) : frame.size.width, frame.size.height == 0 ? BBH(label) : frame.size.height);
    }
    
    // adjust alignment
    if (BBW(label) != frame.size.width && alignment != UITextAlignmentLeft) {
        float xDelta = (frame.size.width - BBW(label)) / (alignment == UITextAlignmentCenter ? 2.0f : 1.0f);
        BBMoveFrame(label, BBX(label) + xDelta, BBY(label));
    }
    
#ifndef BB_DEBUG_LABELS
    label.backgroundColor = [UIColor clearColor];
#else
    label.backgroundColor = [UIColor colorWithRed:BBRnd green:BBRnd blue:BBRnd alpha:0.2];
#endif

    return label;
}

+ (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font frame:(CGRect)frame lineBreakMode:(UILineBreakMode)lineBreakMode {
    return [self labelWithText:text font:font frame:frame lineBreakMode:lineBreakMode alignment:UITextAlignmentLeft];
}

+ (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font {
    return [self labelWithText:text font:font frame:BBEmptyRect(0, 0) lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
}

- (CGFloat)getFrameHeightWithMaxWidth:(CGFloat)maxWidth {
    return [UILabel getFrameHeightFromStringWithMaxHeight:self.text withFont:self.font withMaxWidth:maxWidth withMaxHeight:NSIntegerMax];
}

- (CGFloat)getFrameHeightWithMaxSize:(CGSize)maxSize {
    return [UILabel getFrameHeightFromStringWithMaxHeight:self.text withFont:self.font withMaxWidth:maxSize.width withMaxHeight:maxSize.height];
}

+ (CGFloat)getFrameHeightFromStringWithMaxHeight:(NSString *)string
						  withFont:(UIFont *)font
					  withMaxWidth:(CGFloat)maxWidth
					 withMaxHeight:(CGFloat)maxHeight {
	CGSize stringSize = [string sizeWithFont:font
						   constrainedToSize:CGSizeMake(maxWidth, maxHeight)
							   lineBreakMode:UILineBreakModeWordWrap];

	return stringSize.height;
}

- (void)frameWithOptimalFontForWidth:(float)width
                          withOrigin:(CGPoint)origin
                     withMaxFontSize:(float)maxFontSize
                     withMinFontSize:(float)minFontSize
                        withMaxLines:(int)maxLines {

    //First, set the initial frame to prep for optimizational synchronizingliness
    self.frame = CGRectMake(origin.x, origin.y, width, [@"A" sizeWithFont:self.font].height);
    CGSize stringSize = [self.text sizeWithFont:self.font];
    UIFont *font = self.font;
    int currentLineCount = 1;

    //Algorithm:
    //  1.)Measure string
    //  2.)If it fits, done.
    //  3.)Keep shrinking down to min font size through maxLines trying to find best size
    while(currentLineCount <= maxLines){
        font = [font fontWithSize:self.font.pointSize];
        stringSize = [self.text sizeWithFont:font];
        while (stringSize.width / currentLineCount > self.frame.size.width - 20 && font.pointSize >= minFontSize) {
            font = [font fontWithSize:font.pointSize - 1];
            stringSize = [self.text sizeWithFont:font];
            if (stringSize.width / currentLineCount <= self.frame.size.width - 20) {
                break;
            }
        }

        if (font.pointSize < minFontSize) {
            currentLineCount++;
        }
        else {
            break;
        }
    }

    //Finally, set the fully synchronized frame based on optimized font size
    currentLineCount = MIN(maxLines, currentLineCount);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, stringSize.height * currentLineCount);
    self.font = font;
}

- (void)frameWithOptimalFontForSize:(CGSize)size
                         withOrigin:(CGPoint)origin
                    withMaxFontSize:(float)maxFontSize
                    withMinFontSize:(float)minFontSize
                       withMaxLines:(int)maxLines {
    NSLog(@"Value: %@", self.text);
    NSLog(@"Bounds: %@", NSStringFromCGSize(size));

    //Similar to the width optimization method, except that it also respects height
    //First, set the initial frame to prep for optimizational synchronizingliness
    self.frame = CGRectMake(origin.x, origin.y, size.width, [@"A" sizeWithFont:self.font].height);
    CGSize stringSize = [self.text sizeWithFont:self.font];
    UIFont *font = self.font;
    int currentLineCount = 1;

    //Algorithm:
    //  1.)Measure string
    //  2.)If it fits, done.
    //  3.)Keep shrinking down to min font size through maxLines trying to find best size that also is within the specified height
    while(currentLineCount <= maxLines){
        font = [font fontWithSize:self.font.pointSize];
        stringSize = [self.text sizeWithFont:font];
        NSLog(@"Trying linecount of: %i and starting at fontsize of: %f with minFontSize: %f", currentLineCount, font.pointSize, minFontSize);
        while ((stringSize.width / currentLineCount > self.frame.size.width - 20 || stringSize.height * currentLineCount > size.height) && font.pointSize >= minFontSize) {
            font = [font fontWithSize:font.pointSize - 1];
            stringSize = [self.text sizeWithFont:font];
            NSLog(@"stringSize.width / currentLineCount: %f, self.frame.size.width: %f |||| stringSize.height: %f, self.frame.size.height: %f |||| font.pointSize: %f",
                   stringSize.width / currentLineCount, self.frame.size.width, stringSize.height, self.frame.size.height, font.pointSize);
            if (stringSize.width / currentLineCount <= self.frame.size.width - 20 && stringSize.height * currentLineCount <= size.height) {
                NSLog(@"Breaking");
                break;
            }
        }

        if (font.pointSize < minFontSize) {
            currentLineCount++;
        }
        else {
            break;
        }
    }

    //Finally, set the fully synchronized frame based on optimized font size
    currentLineCount = MIN(maxLines, currentLineCount);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, stringSize.height * currentLineCount);
    self.font = font;
}

@end