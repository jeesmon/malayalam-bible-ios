//
//  UIDeviceHardware.h
//  MobileEdge
//
//  Created by jijo on 26/02/10. This file/source is from Jason Goldberg
//  Copyright 2010 __iEnterprises__.  All rights reserved.  Maintained by __Notetech__.
//

#import <Foundation/Foundation.h>


@interface UIDeviceHardware : NSObject 


+(BOOL) isOS4Device;
+(BOOL) isOS5Device;
+(BOOL) isIpad;
+(BOOL)isSupportRotation:(UIInterfaceOrientation)interfaceOrientation;

@end
