//
//  CircularTimer.m
//
//

#import "CircularTimer.h"

typedef void(^CircularTimerBlock)(void);

@interface CircularTimer ()

@property float radius;
@property float interalRadius;
@property (nonatomic, strong) UIColor *circleStrokeColor;
@property (nonatomic, strong) UIColor *activeCircleStrokeColor;
@property (nonatomic, strong) NSNumber *timerDuration;

@property (nonatomic, copy) CircularTimerBlock startBlock;
@property (nonatomic, copy) CircularTimerBlock endBlock;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSDate *startTime, *endTime;


@property float percentageCompleted;
@property float timeElapsed;
@property BOOL running;

@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton, *dismissButton;
@end

@implementation CircularTimer

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

- (id)initWithPosition:(CGPoint)position
                radius:(float)radius
        internalRadius:(float)internalRadius
     circleStrokeColor:(UIColor *)circleStrokeColor
activeCircleStrokeColor:(UIColor *)activeCircleStrokeColor
             duration:(NSNumber *)duration
         startCallback:(void (^)(void))startBlock
           endCallback:(void (^)(void))endBlock
{
    
    self = [super initWithFrame:CGRectMake(position.x, position.y, radius * 2, radius * 2)];
    if (self) {
        self.radius = radius;
        self.interalRadius = internalRadius;
        self.circleStrokeColor = circleStrokeColor;
        self.activeCircleStrokeColor = activeCircleStrokeColor;
        self.timerDuration = duration;
        self.startBlock = startBlock;
        self.endBlock = endBlock;

        CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self.timerLabel setCenter: center];
        self.timerLabel.backgroundColor =[UIColor greenColor];
        self.timerLabel.textAlignment = NSTextAlignmentCenter;
        self.timerLabel.layer.cornerRadius = self.timerLabel.frame.size.width / 2 ;
        self.timerLabel.clipsToBounds = YES;
        [self.timerLabel setNumberOfLines:2];
        [self.timerLabel setText:[NSString stringWithFormat:@"%0% \n %2d seconds", [self.timerDuration intValue]]];
        [self addSubview: self.timerLabel];


        [self setup];
    }
    return self;
}


- (void)setup
{
    [self customizeAppearance];

    self.percentageCompleted = 0.0f;
    self.timeElapsed = 0;
    self.startTime = [NSDate date];
    self.endTime = [self.startTime dateByAddingTimeInterval:[self.timerDuration floatValue]];
    self.running = NO;
    if ([self worthToRun]) {
        CGFloat timeInterval = 0.1f; // check every 10th of a second
        self.timer = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                      target:self
                                                    selector:@selector(updateCircle:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)customizeAppearance
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    //General circle info
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    float strokeWidth = self.radius - self.interalRadius;
    float radius = self.interalRadius + strokeWidth / 2;
    
    //Background circle
    UIBezierPath *circle1 = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:DEGREES_TO_RADIANS(0.0f)
                                                         endAngle:DEGREES_TO_RADIANS(360.0f)
                                                        clockwise:YES];
    [self.circleStrokeColor setStroke];
    circle1.lineWidth = strokeWidth - 10.f;
    [circle1 stroke];
    
    //Active circle
    float startAngle = 0.0f;
    float degrees = 360.0f;
    
    if ([self worthToRun]) {
        [self updatePercentageCompleted];
        startAngle = 270.0f;
        float tempDegrees = self.percentageCompleted * 360.0 / 100.f;
        degrees = (tempDegrees < 90) ? 270 + tempDegrees : tempDegrees - 90;
    }
    
    UIBezierPath *circle2 = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:DEGREES_TO_RADIANS(startAngle)
                                                         endAngle:DEGREES_TO_RADIANS(degrees)
                                                        clockwise:YES];
    [self.activeCircleStrokeColor setStroke];
    circle2.lineWidth = strokeWidth;
    [circle2 stroke];
    
}

- (void)updateCircle:(NSTimer *)theTimer
{
    if (![self worthToRun]) {
        [self completeRun];
    } else {
        if ([self.startTime compare:[self getCurrentDateGMT]] == NSOrderedAscending &&
            [self.endTime compare:[self getCurrentDateGMT]] == NSOrderedDescending) {
            [self startRun];
        }
    }

    self.timerLabel.text = [NSString stringWithFormat:@"%2.0f%%\n(%2.2f secs)", floor(self.percentageCompleted), (self.timerDuration.floatValue - self.percentageCompleted / 100.f * self.timerDuration.floatValue)];
}

- (void)startRun
{
    if (!self.running) {
        self.running = YES;
        if (self.startBlock != nil) {
            self.startBlock();
        }
    }
    [self setNeedsDisplay];
}

- (void)completeRun
{
    self.running = NO;
    [self.timer invalidate];
    self.percentageCompleted = 100.0f;
    [self setNeedsDisplay];
    if (self.endBlock != nil) {
        self.endBlock();
    }
}

- (void)updatePercentageCompleted
{
    if ([self.startTime compare:[self endTime]] == NSOrderedAscending) {
        float total = [self.endTime timeIntervalSince1970] - [self.startTime timeIntervalSince1970];
        float current = [[NSDate date] timeIntervalSince1970] - [self.startTime timeIntervalSince1970];
        self.timeElapsed = current;
        self.percentageCompleted = current / total * 100;
    } else {
        self.percentageCompleted = 0.0f;
    }

}

- (BOOL)worthToRun
{
    return ([[self endTime] timeIntervalSince1970] > [[self getCurrentDateGMT] timeIntervalSince1970]);
}

- (NSDate *)getCurrentDateGMT
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
}

#pragma mark
#pragma mark Public
#pragma mark

- (BOOL)isRunning
{
    return self.running;
}

- (BOOL)willRun
{
    return [self worthToRun];
}

- (void)stop
{
    [self.timer invalidate];
}

- (void)restart {
    [self setup];
    [self startRun];
}

@end
