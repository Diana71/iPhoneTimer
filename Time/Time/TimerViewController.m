//
//  TimerViewController.m
//  Time
//
//  Created by Diana Elezaj on 8/23/15.
//  Copyright (c) 2015 Mike Kavouras. All rights reserved.
//

#import "TimerViewController.h"
#import "STKSpinnerView.h"
#import <AVFoundation/AVFoundation.h> // this allows us to include sounds!

@interface TimerViewController ()
{
    AVAudioPlayer *_clock;
    AVAudioPlayer *_timerIsOver;
}

@property (strong, nonatomic) IBOutlet UIButton *presetsButton;
@property (weak, nonatomic) IBOutlet STKSpinnerView *spinnerView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *startStopButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseResumeButton;
@property (strong, nonatomic) IBOutlet UIDatePicker *picker;
@property (strong, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) IBOutlet UIImageView *muteImageView;
@property (nonatomic) BOOL muteSound;
@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSTimer *StopwatchTimer;
@property (nonatomic) NSTimer *circularTimerProgress;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) NSInteger elapsedTime;

@property (nonatomic) float progress;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"waterRotated"]];
    [self.presetsButton setBackgroundImage:[UIImage imageNamed:@"krig_Aqua_button"] forState:UIControlStateNormal];
    
    self.picker.hidden = NO;
    self.timeLabel.hidden = YES;
    self.picker.countDownDuration = 60;
    self.muteSound = NO;
    self.isPaused = NO;

    /******  Interface layout *****/
    [self.startStopButton.titleLabel  isEqual: @"START"];
    self.startStopButton.layer.cornerRadius = 60;
    self.startStopButton.clipsToBounds = YES;
    
     [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"drop"] forState:UIControlStateNormal];
    
    self.progress = 0.0;
    
    [self.pauseResumeButton.titleLabel  isEqual: @"PAUSE"];
    self.pauseResumeButton.layer.cornerRadius = 60;
    self.pauseResumeButton.clipsToBounds = YES;
    
    [self.pauseResumeButton setBackgroundImage:[UIImage imageNamed:@"drop"] forState:UIControlStateNormal];
    self.pauseResumeButton.enabled = NO;
    self.spinnerView.hidden = YES;
    self.muteImageView.image = [UIImage imageNamed: @"SoundOn"];
    
#pragma mark - Ringtones
    
    NSString *path = [NSString stringWithFormat:@"%@/Clock-Ticking(1minute).mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    _clock = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    
    
    NSString *path2 = [NSString stringWithFormat:@"%@/TimerIsOff.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl2 = [NSURL fileURLWithPath:path2];
    _timerIsOver = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl2 error:nil];
}

#pragma mark - Buttons

- (IBAction)muteButton:(id)sender {
    
    if (self.muteImageView.image == [UIImage imageNamed: @"SoundOn"]){
    [_clock stop];
        self.muteImageView.image = [UIImage imageNamed: @"SoundOff"];

        NSLog(@"stop");
    }
    else {
        NSLog(@"play");

        [_clock play];
        self.muteImageView.image = [UIImage imageNamed: @"SoundOn"];
    }

}

- (IBAction)startStopButton:(id)sender {

    NSString *startStopActualLabel =  self.startStopButton.titleLabel.text;
    
    // start button tapped
    if ([startStopActualLabel isEqualToString:@"START"] ) {
    [self startTimer:self.picker.countDownDuration];
        
            if (self.muteSound == NO) {
                [_clock play];
            }
        self.progress = 0.0;
        }
    
    else      // stop button tapped
    {
        if (self.muteSound == YES) {
            [_clock stop];
        }
        self.pauseResumeButton.enabled = YES;
        NSLog(@"stop pressed");
        [_clock stop];
        [_timerIsOver stop];
        [self stopTimer];
    }
}

- (IBAction)pauseResumeButtonTapped:(id)sender {
    
    if (self.isPaused == NO) {
        [self pauseTimer];
        self.isPaused = YES;
        [_clock stop];
    
    } else{
        [self resumeTimer];
        self.isPaused = NO;
        if (self.muteSound == NO) {
            [_clock play];
        }
        else if (self.muteSound == YES) {
            [_clock stop];
        }
    }
}


#pragma mark - Timers

- (void)spinit:(NSTimer *)timer
{
    self.progress +=  (0.1/self.duration);
    
    if(self.progress >= 1.0) {
        self.progress = 1.0;
        [timer invalidate];
    }
    [[self spinnerView] setProgress:self.progress animated:YES];
}


- (void)timerFired:(NSTimer *)timer {
    
    NSInteger hours, minutes, seconds ;
    NSDate *now = [[NSDate alloc] init];
    self.elapsedTime = [now timeIntervalSinceDate:self.startTime];
    
    seconds = (self.duration - self.elapsedTime) % 60;
    minutes = ((self.duration - self.elapsedTime) / 60) % 60;
    hours = ((self.duration - self.elapsedTime) / 3600) % 24;

    self.timeLabel.text = [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    
    if (self.elapsedTime == self.duration) {
        [_timerIsOver play];
        [self alertView];
        [timer invalidate];
    }
}

#pragma mark - Time methods

-(void)startTimer:(NSInteger) duration {
    
    // set self.startTime to now
    self.duration = duration;
    self.startTime = [[NSDate alloc] init];
    
    self.StopwatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    self.circularTimerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(spinit:) userInfo:nil repeats:YES];
    
    [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"redDrop"] forState:UIControlStateNormal];
    [self.startStopButton setTitle:@"STOP" forState:UIControlStateNormal];
    
    self.pauseResumeButton.enabled = YES;
    [self.pauseResumeButton setBackgroundImage:[UIImage imageNamed:@"YellowDrop"] forState:UIControlStateNormal];
    
    self.timeLabel.hidden = NO;
    self.picker.hidden = YES;
    self.spinnerView.hidden = NO;
}

-(void) stopTimer {
    
    [self.StopwatchTimer invalidate];
    [self.circularTimerProgress invalidate];
    self.circularTimerProgress = nil;
    
    [self.startStopButton setTitle:@"START" forState:UIControlStateNormal];
    [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"drop"] forState:UIControlStateNormal];

    self.pauseResumeButton.enabled = NO;
    [self.pauseResumeButton setBackgroundImage:[UIImage imageNamed:@"drop"] forState:UIControlStateNormal];

    self.timeLabel.hidden = YES;
    self.picker.hidden = NO;
    self.spinnerView.hidden = YES;
 
}

-(void) pauseTimer {
    
    [self.StopwatchTimer invalidate];
    [self.circularTimerProgress invalidate];
    [self.pauseResumeButton setTitle:@"RESUME" forState:UIControlStateNormal];
    [self.pauseResumeButton setBackgroundImage:[UIImage imageNamed:@"drop"] forState:UIControlStateNormal];
}

- (void) resumeTimer; {
    
    [self startTimer:self.duration - self.elapsedTime];
    [self.pauseResumeButton setTitle:@"PAUSE" forState:UIControlStateNormal];
    [self.pauseResumeButton setBackgroundImage:[UIImage imageNamed:@"YellowDrop"] forState:UIControlStateNormal];
}

#pragma mark - Alert View

-(void) alertView{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TIMER!!" message:@"Time is up!" delegate:self cancelButtonTitle:@"Stop" otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        [ _timerIsOver stop];
        self.timeLabel.hidden = YES;
        self.picker.hidden = NO;
        self.spinnerView.hidden = YES;
    }
}

@end

