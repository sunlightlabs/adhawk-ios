//
//  RecorderViewController.h
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AdHawkBaseViewController.h"
#import "AdHawkAPI.h"

@interface RecorderViewController : AdHawkBaseViewController
<AVAudioRecorderDelegate, AdHawkAPIDelegate>
{
    AVAudioRecorder *audioRecorder;
    UIImageView *_hawktivityAnimatedImageView;
    UIButton *recordButton;
    UIButton *popularResultsButton;
    UIView *failView;
    CLLocationManager *_locationManager;
}
@property (nonatomic, strong) IBOutlet UIImageView *workingBackground;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIView *failView;
- (IBAction)handleTVButtonTouch;
- (IBAction)retryButtonClicked;
- (IBAction)stopRecorder;
- (IBAction)showBrowseWebView;

- (void)setFailState:(BOOL)isFail;
- (void)setWorkingState:(BOOL)isWorking;

@end