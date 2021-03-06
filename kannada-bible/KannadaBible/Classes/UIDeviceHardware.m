//
//  UIDeviceHardware.m
//  MobileEdge
//
//  Created by jijo on 26/02/10.
//  Copyright 2010 __iEnterprises__.  All rights reserved.  Maintained by __Notetech__.
//

#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_5_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_5_0 675.000000
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0 //50000

#define IF_IOS5_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_5_0) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS5_OR_GREATER(...)
#endif


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#define IF_IOS4_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) \
    { \
        __VA_ARGS__ \
    }
#else
#define IF_IOS4_OR_GREATER(...)
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
#define IF_3_2_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2) \
    { \
        __VA_ARGS__ \
    }
#else 
#define IF_3_2_OR_GREATER(...)
#endif

//static NSString* deviceStr = nil;

@implementation UIDeviceHardware


- (NSString *) platform{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

//mod+20111011
- (NSString *) platformString{
	NSString *platform = [self platform];
	    
	if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])         return @"Simulator";
		//
	return platform;
}
+(BOOL) isIpad{
    
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
}

+(BOOL) isOS4Device{

	IF_IOS4_OR_GREATER(
	
	   return YES;
	   	
	);
	return NO;
}
+(BOOL)isOS5Device {
    
    IF_IOS5_OR_GREATER(
        
        return YES;
    )
    return NO;
    /*
    NSString *osVersion = @"5.0";
    NSString *currOsVersion = [[UIDevice currentDevice] systemVersion];
    return [currOsVersion compare:osVersion options:NSNumericSearch] == NSOrderedAscending;*/
}
+(BOOL)isSupportRotation:(UIInterfaceOrientation)interfaceOrientation{
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    //if([self isiPad]) 
    //else return YES;
   
}
@end
