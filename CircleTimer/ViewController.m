//
//  ViewController.m
//  CircleTimer
//
//  Created by Michael Nguyen on 2/28/15.
//  Copyright (c) 2015 Michael Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "TimerViewController.h"

@interface ViewController () <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSInteger numMinutes, numSeconds;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *circleStrokeColorSegmentedControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *activeCircleStrokeColorSegmentedControl;
@property (nonatomic, weak) IBOutlet UISlider *radiusSlider;
@property (nonatomic, weak) IBOutlet UISlider *internalRadiusSlider;
@property (nonatomic, weak) IBOutlet UIButton *initialDateButton;
@property (nonatomic, weak) IBOutlet UIButton *finalDateButton;
@property (nonatomic, weak) IBOutlet UILabel *radiusLabel;
@property (nonatomic, weak) IBOutlet UILabel *interalRadiusLabel;

@property (nonatomic, weak) IBOutlet UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UITextField *timerTextField;

@property (nonatomic, strong) UIPickerView *timePicker;


- (IBAction)showPicker:(id)sender;
- (IBAction)slideRadius:(id)sender;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    numMinutes = 0;
    numSeconds = 0;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.timePicker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, screenRect.size.height, screenRect.size.width, 216)];
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    self.timePicker.backgroundColor = [UIColor grayColor];

     [self.view addSubview:self.timePicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - slider control
- (IBAction)slideRadius:(UISlider *)sender
{
    NSString* formattedValue = [NSString stringWithFormat:@"%.f", sender.value];

    if (sender.tag == 303) {
        self.radiusLabel.text = [NSString stringWithFormat:@"Radius (%@)", formattedValue];
    } else if (sender.tag == 404) {
        self.interalRadiusLabel.text = [NSString stringWithFormat:@"Internal Radius (%@)", formattedValue];
    }
}


#pragma mark - UIPicker delegates
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  2;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        numMinutes = row;
    }
    else {
        numSeconds = row ;
    }

    [self changeDuration:pickerView];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *label = nil;
    if (component == 0) {
        label = [NSString stringWithFormat:@"%d Minutes", row];
    }
    else {
        label = [NSString stringWithFormat:@"%d Seconds", row];
    }

    return label;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 24;
    }

    return 60;
}

- (void)changeDuration: (UIPickerView *)pickerView {
    NSInteger selectedMin = [pickerView selectedRowInComponent:0];
    NSInteger selectedSec = [pickerView selectedRowInComponent:1];

    self.timerTextField.text = [NSString stringWithFormat: @"%2.2d:%2.2d", selectedMin, selectedSec];
}

- (IBAction)showPicker:(UIButton *)sender
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.timePicker setHidden:NO];
    self.timePicker.tag = sender.tag;
    [self addCancelView];
    [UIView animateWithDuration:0.3 animations:^{
        self.timePicker.frame = CGRectMake(0, screenRect.size.height - 216, 320, 216);
    }];

}


- (void)addCancelView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker:)];
    [self.view addGestureRecognizer:tap];

}

- (void)hidePicker:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [UIView animateWithDuration:0.3 animations:^{
        self.timePicker.frame = CGRectMake(0, screenRect.size.height + 216, 320, 216);
    }];

}

- (UIColor *)getColorForSelectedSegmentedControl:(UISegmentedControl *)sg
{
    switch (sg.selectedSegmentIndex) {
        case 0:
            return [UIColor lightGrayColor];
            break;
        case 1:
            return [UIColor purpleColor];
            break;
        case 2:
            return [UIColor blackColor];
            break;
        case 3:
            return [UIColor redColor];
            break;
        default:
            break;
    }
    return [UIColor whiteColor];
}


#pragma mark
#pragma mark Segue
#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTImer"]) {
        TimerViewController *detailViewController = [segue destinationViewController];
        detailViewController.radius = round(self.radiusSlider.value);
        detailViewController.internalRadius = round(self.internalRadiusSlider.value);
        detailViewController.timerDuration = [NSNumber numberWithInt: (numMinutes * 60 + numSeconds)];

        detailViewController.activeCircleStrokeColor = [self getColorForSelectedSegmentedControl:self.activeCircleStrokeColorSegmentedControl];
        detailViewController.circleStrokeColor = [self getColorForSelectedSegmentedControl:self.circleStrokeColorSegmentedControl];
    }
}



@end
