//
//  AdhawkErrorViewController.h
//  adhawk
//
//  Created by Daniel Cloud on 7/31/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHawkBaseViewController.h"

@interface AdhawkErrorViewController : AdHawkBaseViewController

@property (nonatomic, strong) IBOutlet UIButton *popularResultsButton;
@property (nonatomic, strong) IBOutlet UIButton *tryAgainButton;
@property (nonatomic, strong) IBOutlet UIButton *whyNoResultsButton;

@end
