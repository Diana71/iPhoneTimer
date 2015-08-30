//
//  TimerViewController.m
//  Time
//
//  Created by Diana Elezaj on 8/23/15.
//  Copyright (c) 2015 Mike Kavouras. All rights reserved.
//

#import "TimerViewController.h"
#import "TimerDetailTableViewController.h"

@interface TimerViewController ()

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *startStopButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseResumeButton;
@property (strong, nonatomic) IBOutlet UIDatePicker *picker;
@property (nonatomic) NSDate *startTime;  //
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL isPaused;

@property (nonatomic) NSInteger elapsedTime;


@end

@implementation TimerViewController



- (void)viewDidLoad {
	[super viewDidLoad];
	self.picker.hidden = NO;
	self.timeLabel.hidden = YES;
	self.picker.countDownDuration = 60;
	
	self.isPaused = NO;
	
	/******  Interface layout *****/
	[self.startStopButton.titleLabel  isEqual: @"START"];
	self.startStopButton.layer.cornerRadius = 60;
	self.startStopButton.clipsToBounds = YES;
	self.startStopButton.backgroundColor = [UIColor colorWithRed:0.31 green:0.60 blue:0.19 alpha:1.0];
	
	[self.pauseResumeButton.titleLabel  isEqual: @"PAUSE"];
	self.pauseResumeButton.layer.cornerRadius = 60;
	self.pauseResumeButton.clipsToBounds = YES;
	self.pauseResumeButton.backgroundColor = [UIColor redColor];
}

- (void)timerFired:(NSTimer *)timer {
	NSLog(@"hi hi");
	NSDate *now = [[NSDate alloc] init];
	self.elapsedTime = [now timeIntervalSinceDate:self.startTime];
	
	
	self.timeLabel.text = [NSString stringWithFormat:@"%lu", self.duration - self.elapsedTime];
}

- (IBAction)startStopButton:(id)sender {
	
	//	self.duration = self.picker.countDownDuration;
	
	NSLog(@"i clicked start");
	NSString *startStopActualLabel =  self.startStopButton.titleLabel.text;
	if ([startStopActualLabel isEqualToString:@"START"] ) {
		
		[self startTimer:self.picker.countDownDuration];
		
	} else {
		NSLog(@"else");
		[self stopTimer];
		
	}
	
}

-(void)startTimer:(NSInteger) duration {
	// set self.startTime to now
	
	self.duration = duration;
	self.startTime = [[NSDate alloc] init];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
	// change the button label to "Stop" so we know it's running
	[self.startStopButton setTitle:@"STOP" forState:UIControlStateNormal];
	
	self.timeLabel.hidden = NO;
	self.picker.hidden = YES;
	
	self.timeLabel.text = [NSString stringWithFormat:@"%lu", self.duration];
}

-(void) stopTimer {
	[self.timer invalidate];
	
	[self.startStopButton setTitle:@"START" forState:UIControlStateNormal];
	
	self.timeLabel.hidden = YES;
	self.picker.hidden = NO;
	
}

-(void) pauseTimer {
	[self.timer invalidate];
	[self.pauseResumeButton setTitle:@"RESUME" forState:UIControlStateNormal];
}
	


//-(void) resumeTimer {
//	[self.pauseResumeButton setTitle:@"RESUME" forState:UIControlStateNormal];
//	self.timeLabel.hidden = NO;
//	self.picker.hidden = YES;
//	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:[self pauseTimer] userInfo:nil repeats:NO];
//	}

	

- (void) resumeTimer; {
	[self startTimer:self.duration - self.elapsedTime];
	[self.pauseResumeButton setTitle:@"PAUSE" forState:UIControlStateNormal];
}



- (IBAction)pauseResumeButtonTapped:(id)sender {
	
	
	if (self.isPaused == NO) {
		[self pauseTimer];
		self.isPaused = YES;
		
	} else{
		[self resumeTimer];
		self.isPaused = NO;
	}
	
	

	
	
	
	
}

@end
