//
//  TimerViewController.h
//  CircleTimer
//
//  Created by Michael Nguyen on 2/28/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController

@property float radius;
@property float internalRadius;
@property (nonatomic, strong) UIColor *circleStrokeColor;
@property (nonatomic, strong) UIColor *activeCircleStrokeColor;
@property (nonatomic, strong) NSNumber *timerDuration;


@end
