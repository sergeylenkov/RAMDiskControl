//
//  PTLoginItem.h
//  QuickTranslate
//
//  Created by Sergey Lenkov on 15.01.11.
//  Copyright 2011 Positive Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PTLoginItem : NSObject {

}

+ (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )loginItemsRefs forPath:(NSString *)path;
+ (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )loginItemsRefs forPath:(NSString *)path;
+ (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)loginItemsRefs forPath:(NSString *)path;
+ (BOOL)willStartAtLogin:(NSURL *)itemURL;
+ (void)setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;

@end
