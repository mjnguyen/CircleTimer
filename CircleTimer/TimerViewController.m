//
//  TimerViewController.m
//  CircleTimer
//
//  Created by Michael Nguyen on 2/28/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "TimerViewController.h"
#import "CircularTimer.h"

@interface TimerViewController ()

@property (nonatomic, strong) CircularTimer *circularTimer;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)viewWillAppear:(BOOL)animated
{
    [self createCircle];
}

- (void)createCircle
{
    CGPoint centroid = CGPointMake(self.view.frame.size.width/4, 50.0f);
    self.circularTimer = [[CircularTimer alloc] initWithPosition:centroid
                                                          radius:self.radius
                                                  internalRadius:self.internalRadius
                                               circleStrokeColor:self.circleStrokeColor
                                         activeCircleStrokeColor:self.activeCircleStrokeColor
                                                        duration:self.timerDuration
                                                   startCallback:^{
                                                       // put some code here to deal with startup
                                                   }
                                                     endCallback:^{
                                                         // put some code here to deal with ending of timer

                                                     }];

    [self.view addSubview:self.circularTimer];
}

- (IBAction)dismiss:(id)sender
{
    self.circularTimer = nil;
    [self.circularTimer removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startTimer:(id)sender {
    [self.circularTimer restart];
}


@end
