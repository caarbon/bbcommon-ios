//
//  BBKenBurnsView.h
//  BBCommon
//
//  Created by Lee Brenner on 2/27/12.
//  Copyright 2012 BigBig Bomb, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBKenBurnsView : UIView
@property(nonatomic, retain) NSMutableArray *images;

@property(nonatomic, retain) UIImageView *imageA;

@property(nonatomic, retain) UIImageView *imageB;

@property(nonatomic) float durationMinimum;

@property(nonatomic) float durationMaximum;

@property(nonatomic) float scaleMinimum;

@property(nonatomic) float scaleMaximum;

@property(nonatomic) float translateMinimum;

@property(nonatomic) float translateMaximum;

- (id)initWithFrame:(CGRect)frame andImages:(NSMutableArray *)images;

- (void)startAnimating;

- (void)stopAnimating;

@end