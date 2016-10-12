//
//  PTLoginItem.m
//  QuickTranslate
//
//  Created by Sergey Lenkov on 15.01.11.
//  Copyright 2011 Positive Team. All rights reserved.
//

#import "PTLoginItem.h"

@implementation PTLoginItem

+ (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )loginItemsRefs forPath:(NSString *)path {
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
    
	if (item) {
		CFRelease(item);
    }
}

+ (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )loginItemsRefs forPath:(NSString *)path {
	UInt32 seedValue;
	CFURLRef pathRef;

	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItemsRefs, &seedValue);
    
	for (id item in (NSArray *)loginItemsArray) {		
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
        
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &pathRef, NULL) == noErr) {
			if ([[(NSURL *)pathRef path] hasPrefix:path]) {
				LSSharedFileListItemRemove(loginItemsRefs, itemRef);
			}

			CFRelease(pathRef);
		}		
	}
    
	CFRelease(loginItemsArray);
}

+ (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)loginItemsRefs forPath:(NSString *)path {
	UInt32 seedValue;
	CFURLRef pathRef;
    BOOL isExists = NO;  
    
	CFArrayRef loginItemsArrayRef = LSSharedFileListCopySnapshot(loginItemsRefs, &seedValue);
    
	for (id item in (NSArray *)loginItemsArrayRef) {    
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
        
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &pathRef, NULL) == noErr) {
			if ([[(NSURL *)pathRef path] hasPrefix:path]) {
				isExists = YES;
				break;
			}
		}

		CFRelease(pathRef);
	}
    
    if (loginItemsArrayRef) {
        CFRelease(loginItemsArrayRef);
    }
    
	return isExists;
}

+ (BOOL) willStartAtLogin:(NSURL *)itemURL {
    Boolean foundIt=false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                foundIt = CFEqual(URL, itemURL);
                CFRelease(URL);
                
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return (BOOL)foundIt;
}

+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled {
    //OSStatus status;
    LSSharedFileListItemRef existingItem = NULL;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, itemURL);
                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
        
        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
                                          NULL, NULL, (CFURLRef)itemURL, NULL, NULL);
            
        } else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);
        
        CFRelease(loginItems);
    }       
}

@end
