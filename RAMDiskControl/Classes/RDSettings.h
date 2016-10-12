//
//  RDSettings.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 11.09.12.
//
//

#import <Foundation/Foundation.h>
#import "RDDisk.h"

@interface RDSettings : NSObject {
	NSUserDefaults *defaults;
}

@property (nonatomic, assign) BOOL autosave;
@property (nonatomic, assign) NSInteger autosaveInterval;
@property (nonatomic, assign) BOOL saveOnQuit;
@property (nonatomic, copy) NSString *savePath;

+ (RDSettings *)sharedSettings;

- (void)saveDisk:(RDDisk *)disk;
- (void)removeDisk:(RDDisk *)disk;
- (NSArray *)loadDisks;
- (BOOL)isDiskExists:(NSString *)name;

@end
