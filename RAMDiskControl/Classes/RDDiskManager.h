//
//  RDDiskManager.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import <Foundation/Foundation.h>
#import "RDDisk.h"

@class RDDiskManager;

@protocol RDDiskManagerDelegate <NSObject>

- (void)diskManager:(RDDiskManager *)manager didCreatedDisk:(RDDisk *)disk;
- (void)diskManager:(RDDiskManager *)manager didRemovedDisk:(RDDisk *)disk;
- (void)diskManager:(RDDiskManager *)manager didMountedDisk:(RDDisk *)disk;
- (void)diskManager:(RDDiskManager *)manager didUnmountedDisk:(RDDisk *)disk;

@end

@interface RDDiskManager : NSObject

@property (nonatomic, assign) id <RDDiskManagerDelegate> delegate;

+ (RDDiskManager *)sharedManager;

- (void)createDisk:(NSString *)name size:(NSUInteger)size autoMount:(BOOL)mount;
- (void)mountDisk:(RDDisk *)disk error:(NSError **)error;
- (void)unmountDisk:(RDDisk *)disk;
- (void)saveDisk:(RDDisk *)disk;
- (void)restoreDisk:(RDDisk *)disk;
- (BOOL)isDiskExists:(RDDisk *)disk;

@end
