//
//  UIDeviceHardware.h
//  DeviceDNA
//
//  Created by Adrian on 3/25/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

// This class was adapted from
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

@interface UIDeviceHardware : NSObject 

+ (NSString *)platform;
+ (NSString *)platformString;

@end
