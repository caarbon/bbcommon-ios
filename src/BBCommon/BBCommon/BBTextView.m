//
//  Created by Brian Romanko on 6/1/12.
//  Copyright 2011 BigBig Bomb, LLC. All rights reserved.
//
#import "BBTextView.h"

@implementation BBTextView
@synthesize textInsets = _textInsets;

- (id)initWithFrame:(CGRect)frame andInsets:(UIEdgeInsets)insets {
    self = [super initWithFrame:frame];
    if (self) {
        self.textInsets = insets;
    }

    return self;
}

- (CGRect)newBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.textInsets.left,
            bounds.origin.y + self.textInsets.top,
            bounds.size.width - self.textInsets.left - self.textInsets.right,
            bounds.size.height - self.textInsets.top - self.textInsets.bottom);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self newBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self newBounds:bounds];
}

@end