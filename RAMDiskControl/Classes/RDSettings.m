//
//  RDSettings.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 11.09.12.
//
//

#import "RDSettings.h"

static RDSettings *_sharedSettings = nil;

@implementation RDSettings

@synthesize autosave;
@synthesize autosaveInterval;
@synthesize saveOnQuit;
@synthesize savePath;

+ (RDSettings *)sharedSettings {
	if (_sharedSettings == nil) {
		_sharedSettings = [[RDSettings alloc] init];
	}
	
	return _sharedSettings;
}

- (id)init {
	self = [super init];
	
	if (self) {
		defaults = [NSUserDefaults standardUserDefaults];
	}
	
	return self;
}

- (void)saveDisk:(RDDisk *)disk {
	[self removeDisk:disk];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:disk.name forKey:@"name"];
	[dict setObject:disk.disk forKey:@"disk"];
	[dict setObject:[NSNumber numberWithInteger:disk.size] forKey:@"size"];
	[dict setObject:[NSNumber numberWithBool:disk.autoMount] forKey:@"autoMount"];
	
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[defaults objectForKey:@"Disks"]];
	
	[temp addObject:dict];
	
	[defaults setObject:temp forKey:@"Disks"];
}

- (void)removeDisk:(RDDisk *)disk {
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[defaults objectForKey:@"Disks"]];
	
	for (NSDictionary *dict in temp) {
		if ([disk.name isEqualToString:[dict objectForKey:@"name"]]) {
			[temp removeObject:dict];
			break;
		}
	}
	
	[defaults setObject:temp forKey:@"Disks"];
}

- (NSArray *)loadDisks {
	NSArray *temp = [defaults objectForKey:@"Disks"];
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSDictionary *dict in temp) {
		RDDisk *disk = [[RDDisk alloc] init];
		
		disk.name = [dict objectForKey:@"name"];
		disk.disk = [dict objectForKey:@"disk"];
		disk.size = [[dict objectForKey:@"size"] integerValue];
		disk.autoMount = [[dict objectForKey:@"autoMount"] boolValue];
		
		[result addObject:disk];
		[disk release];
	}
	
	return result;
}

- (BOOL)isDiskExists:(NSString *)name {
	NSArray *temp = [defaults objectForKey:@"Disks"];
	
	for (NSDictionary *dict in temp) {
		if ([name isEqualToString:[dict objectForKey:@"name"]]) {
			return YES;
		}
	}
	
	return NO;
}

- (void)setAutosave:(BOOL)state {
	[defaults setBool:state forKey:@"Autosave"];
}

- (BOOL)autosave {
	if ([defaults objectForKey:@"Autosave"] == nil) {
		[defaults setBool:NO forKey:@"Autosave"];
	}
	
	return [defaults boolForKey:@"Autosave"];
}

- (void)setAutosaveInterval:(NSInteger)interval {
	[defaults setInteger:interval forKey:@"Autosave Interval"];
}

- (NSInteger)autosaveInterval {
	if ([defaults objectForKey:@"Autosave Interval"] == nil) {
		[defaults setInteger:10 forKey:@"Autosave Interval"];
	}
	
	return [defaults integerForKey:@"Autosave Interval"];
}

- (void)setSaveOnQuit:(BOOL)state {
	[defaults setBool:state forKey:@"Save On Quit"];
}

- (BOOL)saveOnQuit {
	if ([defaults objectForKey:@"Save On Quit"] == nil) {
		[defaults setBool:NO forKey:@"Save On Quit"];
	}
	
	return [defaults boolForKey:@"Save On Quit"];
}

- (void)setSavePath:(NSString *)path {
	[defaults setObject:path forKey:@"Save Path"];
}

- (NSString *)savePath {
	if ([defaults objectForKey:@"Save Path"] == nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *path = [paths objectAtIndex:0];
		
		[defaults setObject:path forKey:@"Save Path"];
	}
	
	return [defaults objectForKey:@"Save Path"];
}
@end
