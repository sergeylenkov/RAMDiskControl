//
//  RDDisk.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import <Foundation/Foundation.h>

@interface RDDisk : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *disk;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, assign) BOOL isMounted;
@property (nonatomic, assign) BOOL autoMount;

@end
