//
//  AppMacros.h
//  adhawk
//
//  Created by Daniel Cloud on 7/20/12.
//  Copyright (c) 2012 Sunlight Foundation. All rights reserved.
//

#ifndef adhawk_AppMacros_h
#define adhawk_AppMacros_h


#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;


#endif
