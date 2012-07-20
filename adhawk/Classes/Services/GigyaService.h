//
//  GigyaService.h
//  adhawk
//
//  Created by Daniel Cloud on 7/20/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAPI.h"

GSAPI *getAPIObject(void);
GSObject *getParamsObject(void);

@interface GigyaService : NSObject <UIApplicationDelegate, GSAddConnectionsUIDelegate, GSEventDelegate, GSLoginUIDelegate, GSResponseDelegate> {
    GSAPI *_api;
    GSObject *_params;
}
+ (GigyaService *)sharedInstanceWithViewController:(UIViewController *)mainViewController;
- (void) showLoginUI;

@property (readonly, nonatomic) GSAPI *api;
@property (readonly, nonatomic) GSObject *params;

@end
