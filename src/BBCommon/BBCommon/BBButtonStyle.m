//
//  Created by Lee Fastenau on 8/11/11.
//  Copyright 2011 BigBig Bomb, LLC. All rights reserved.
//
#import "BBButtonStyle.h"
#import <objc/runtime.h>

static char *bbButtonStyleKey = "bbButtonStyle";

@implementation UIButton (BBButtonStyle)

// swizzled methods
-(void)setHighlighted2:(BOOL)highlight {
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
    [self setHighlighted2:highlight];
#pragma clang diagnostic pop
    BBButtonStyle *style = objc_getAssociatedObject(self, &bbButtonStyleKey);
    [style performSelector:@selector(updateAppearance:) withObject:self];}

-(void)setSelected2:(BOOL)selected {
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
    [self setSelected2:selected];
#pragma clang diagnostic pop
    BBButtonStyle *style = objc_getAssociatedObject(self, &bbButtonStyleKey);
    [style performSelector:@selector(updateAppearance:) withObject:self];}

-(void)setEnabled2:(BOOL)enabled {
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
    [self setEnabled2:enabled];
#pragma clang diagnostic pop
    BBButtonStyle *style = objc_getAssociatedObject(self, &bbButtonStyleKey);
    [style performSelector:@selector(updateAppearance:) withObject:self];}

@end

@interface BBButtonStyle ()

@property(nonatomic, strong) NSMutableDictionary *labelStyleForState;
@property(nonatomic, strong) NSMutableDictionary *backgroundImageForState;
@property(nonatomic, strong) NSMutableDictionary *imageForState;

@end

@implementation BBButtonStyle

@synthesize buttonCustomizer = _buttonCustomizer;
@synthesize backgroundImageForState = _backgroundImageForState;
@synthesize imageForState = _imageForState;
@synthesize labelStyleForState = _labelStyleForState;

- (BBLabelStyle *)labelStyleForState:(NSUInteger)state {
    return [self.labelStyleForState objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)setLabelStyle:(BBLabelStyle *)image forState:(NSUInteger)state {
    [self.labelStyleForState setObject:image forKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (UIImage *)backgroundImageForState:(NSUInteger)state {
    return [self.backgroundImageForState objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)setBackgroundImage:(UIImage *)image forState:(NSUInteger)state {
    [self.backgroundImageForState setObject:image forKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (UIImage *)imageForState:(NSUInteger)state {
    return [self.imageForState objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)setImage:(UIImage *)image forState:(NSUInteger)state {
    [self.imageForState setObject:image forKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)updateAppearance:(UIButton *)button {
    BBLabelStyle *style = [self.labelStyleForState objectForKey:[NSNumber numberWithUnsignedInteger:button.state]];
    if (style) {
        button.titleLabel.shadowOffset = style.shadowOffset;
        button.titleLabel.font = style.font;
    }
    if (self.buttonCustomizer) self.buttonCustomizer(button, self);
}

- (void)applyStyleToButton:(UIButton *)button
{
    for (NSNumber *controlState in self.labelStyleForState) {
        BBLabelStyle *style = [self.labelStyleForState objectForKey:controlState];
        [button setTitleColor:style.color forState:[controlState unsignedIntegerValue]];
        [button setTitleShadowColor:style.shadowColor forState:[controlState unsignedIntegerValue]];
    }

    for (NSNumber *controlState in self.backgroundImageForState) {
        [button setBackgroundImage:[self.backgroundImageForState objectForKey:controlState] forState:[controlState unsignedIntegerValue]];
    }

    for (NSNumber *controlState in self.imageForState) {
        [button setImage:[self.imageForState objectForKey:controlState] forState:[controlState unsignedIntegerValue]];
    }

    if (self.buttonCustomizer) self.buttonCustomizer(button, self);

    objc_setAssociatedObject(button, &bbButtonStyleKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateAppearance:button];
}


- (UIButton *)buttonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;    
    [button setTitle:title forState:UIControlStateNormal];
    
    [self applyStyleToButton:button];
    return button;
}

- (id)copyWithZone:(NSZone *)zone {
    BBButtonStyle *copy = [[BBButtonStyle allocWithZone:zone] init];
    
    for (NSNumber *key in self.labelStyleForState) {
        [copy.labelStyleForState setObject:[self.labelStyleForState objectForKey:key] forKey:key];
    }
    
    for (NSNumber *key in self.backgroundImageForState) {
        [copy.backgroundImageForState setObject:[self.backgroundImageForState objectForKey:key] forKey:key];
    }
    
    copy.buttonCustomizer = self.buttonCustomizer;
    return copy;
}

- (id)init {
    self = [super init];
    if (self) {
        self.labelStyleForState = [[NSMutableDictionary alloc] init];
        self.backgroundImageForState = [[NSMutableDictionary alloc] init];
        self.imageForState = [[NSMutableDictionary alloc] init];
    }

    return self;
}


@end