//
//  RDDisk.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import "RDDisk.h"

@implementation RDDisk

@synthesize name;
@synthesize disk;
@synthesize size;
@synthesize isMounted;
@synthesize autoMount;

- (void)dealloc {
	[name release];
	[disk release];
	[super dealloc];
}

@end
