//
//  RecorderViewController.h
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AdHawkBaseViewController.h"
#import "AdHawkAPI.h"

//@protocol RecorderViewDelegate <NSObject>
//@required
//- (void) recorderDidGenerateFingerPrint:(NSString *)fingerprint;
//@end

@interface RecorderViewController : AdHawkBaseViewController
<AVAudioRecorderDelegate, AVAudioPlayerDelegate, AdHawkAPIDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    UIButton *recordButton;
    UIButton *popularResultsButton;
    UILabel *label;
    UIView *failView;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIButton *popularResultsButton;
@property (nonatomic, strong) IBOutlet UIView *failView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
-(IBAction) recordAudio;
-(IBAction) playAudio;
-(IBAction) stopRecorder;
-(IBAction) showBrowseWebView;

-(void)setFailState:(BOOL)isFail;

@end