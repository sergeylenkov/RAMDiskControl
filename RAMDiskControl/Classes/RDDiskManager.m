//
//  RDDiskManager.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import "RDDiskManager.h"

static RDDiskManager *_diskManager = nil;

@implementation RDDiskManager

@synthesize delegate;

+ (RDDiskManager *)sharedManager {
	if (_diskManager == nil) {
		_diskManager = [[RDDiskManager alloc] init];
	}
	
	return _diskManager;
}

- (void)createDisk:(NSString *)name size:(NSUInteger)size autoMount:(BOOL)mount {
	RDDisk *disk = [[[RDDisk alloc] init] autorelease];
	
	disk.name = name;
	disk.disk = @"";
	disk.size = size;
	disk.autoMount = mount;
	
	if (delegate && [delegate respondsToSelector:@selector(diskManager: didCreatedDisk:)]) {
		[delegate diskManager:self didCreatedDisk:disk];
	}
}

- (void)mountDisk:(RDDisk *)disk error:(NSError **)error {
	if ([self isDiskExists:disk]) {
		disk.isMounted = YES;
		
		NSTask *task = [[NSTask alloc] init];
		[task setLaunchPath: @"/bin/sh"];
		
		NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"diskutil info /Volumes/%@", disk.name], nil];
		[task setArguments:arguments];
		
		NSPipe *outPipe = [NSPipe pipe];
		[task setStandardOutput:outPipe];
		
		[task launch];
		[task waitUntilExit];
		
		[task release];
		
		NSFileHandle *read = [outPipe fileHandleForReading];
		NSData *dataRead = [read readDataToEndOfFile];
		NSString *stringRead = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
		NSLog(@"output: %@", stringRead);
		
		NSArray *components = [stringRead componentsSeparatedByString:@"\n"];
		NSString *diskNumber = [components objectAtIndex:0];
		NSRange range = [diskNumber rangeOfString:@"disk"];
		
		disk.disk = [diskNumber substringFromIndex:range.location];
		
		if (delegate && [delegate respondsToSelector:@selector(diskManager: didMountedDisk:)]) {
			[delegate diskManager:self didMountedDisk:disk];
		}
		
		return;
	}
	
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"diskutil erasevolume HFS+ \"%@\" `hdiutil attach -nomount ram://%ld`", disk.name, disk.size / 512], nil];
    [task setArguments:arguments];
    
	NSPipe *outPipe = [NSPipe pipe];
	[task setStandardOutput:outPipe];
	
    [task launch];
	[task waitUntilExit];
	
	int status = [task terminationStatus];
	
	[task release];
	
	NSLog(@"STATUS %d %ld", status, disk.size);
	
	NSFileHandle *read = [outPipe fileHandleForReading];
	NSData *dataRead = [read readDataToEndOfFile];
	NSString *stringRead = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"output: %@", stringRead);
	
	NSArray *components = [stringRead componentsSeparatedByString:@"\n"];
	NSString *diskNumber = [components objectAtIndex:0];
	NSRange range = [diskNumber rangeOfString:@"disk"];
	
	disk.disk = [diskNumber substringFromIndex:range.location];
	disk.isMounted = YES;

	if (delegate && [delegate respondsToSelector:@selector(diskManager: didMountedDisk:)]) {
		[delegate diskManager:self didMountedDisk:disk];
	}
}

- (void)unmountDisk:(RDDisk *)disk {
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"umount /Volumes/%@", disk.name], nil];
    [task setArguments:arguments];
	
    [task launch];
	[task waitUntilExit];
	
	[task release];
	
	task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"hdiutil detach %@", disk.disk], nil];
    [task setArguments:arguments];
	
    [task launch];
	[task waitUntilExit];
	
	[task release];
	
	disk.isMounted = NO;
	
	if (delegate && [delegate respondsToSelector:@selector(diskManager: didUnmountedDisk:)]) {
		[delegate diskManager:self didUnmountedDisk:disk];
	}
}

- (void)saveDisk:(RDDisk *)disk {
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
	NSString *path = [[RDSettings sharedSettings].savePath stringByAppendingPathComponent:disk.name];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
	
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"rsync -av --delete /Volumes/%@/ %@", disk.name, [path stringByStandardizingPath]], nil];
    [task setArguments:arguments];
	
	NSPipe *outPipe = [NSPipe pipe];
	[task setStandardOutput:outPipe];
	
    [task launch];
	[task waitUntilExit];
	
	[task release];
	
	NSFileHandle *read = [outPipe fileHandleForReading];
	NSData *dataRead = [read readDataToEndOfFile];
	NSString *stringRead = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"output: %@", stringRead);
}

- (void)restoreDisk:(RDDisk *)disk {
	NSString *path = [[RDSettings sharedSettings].savePath stringByAppendingPathComponent:disk.name];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return;
	}
	
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
	path = [path stringByAppendingString:@"/"];
	
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
	
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"rsync -av %@ /Volumes/%@/", path, disk.name], nil];
    [task setArguments:arguments];
	
	NSPipe *outPipe = [NSPipe pipe];
	[task setStandardOutput:outPipe];
	
    [task launch];
	[task waitUntilExit];
	
	[task release];
	
	NSFileHandle *read = [outPipe fileHandleForReading];
	NSData *dataRead = [read readDataToEndOfFile];
	NSString *stringRead = [[[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"output: %@", stringRead);
}

- (BOOL)isDiskExists:(RDDisk *)disk {
	NSString *path = [@"/Volumes" stringByAppendingPathComponent:disk.name];
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
