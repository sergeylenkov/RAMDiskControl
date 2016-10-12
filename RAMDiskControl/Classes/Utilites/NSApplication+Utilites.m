//
//  NSApplication+Utilites.m
//
//  Created by Sergey Lenkov on 01.08.11.
//  Copyright 2011 Sergey Lenkov. All rights reserved.
//

#import "NSApplication+Utilites.h"

@implementation NSApplication (Utilites)

- (void)getSystemVersionMajor:(unsigned *)major minor:(unsigned *)minor bugFix:(unsigned *)bugFix; {
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) {
        if (major) *major = 10;
        if (minor) *minor = 0;
        if (bugFix) *bugFix = 0;
    } else if (systemVersion < 0x1040) {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 +
            ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugFix) *bugFix = (systemVersion & 0x000F);
    } else {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) {
            if (major) *major = 10;
            if (minor) *minor = 0;
            if (bugFix) *bugFix = 0;
        }
        
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr)  {
            if (major) *major = 10;
            if (minor) *minor = 0;
            if (bugFix) *bugFix = 0;
        }
        
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr)  {
            if (major) *major = 10;
            if (minor) *minor = 0;
            if (bugFix) *bugFix = 0;
        }
        
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugFix) *bugFix = versionBugFix;
    }
}

- (BOOL)isLion {
    unsigned major, minor, bugFix;
    [self getSystemVersionMajor:&major minor:&minor bugFix:&bugFix];
    
    if (major == 10 && minor == 7) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isMountainLion {
    unsigned major, minor, bugFix;
    [self getSystemVersionMajor:&major minor:&minor bugFix:&bugFix];
    
    if (major == 10 && minor == 8) {
        return YES;
    }
    
    return NO;
}

- (void)redirectConsoleLogToDocumentFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *logPath = [documentsDirectory	stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", [[NSBundle mainBundle] bundleIdentifier]]];
	freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
}

@end
