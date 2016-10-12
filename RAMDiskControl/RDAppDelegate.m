//
//  RDAppDelegate.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import "RDAppDelegate.h"
#import "NSApplication+Utilites.h"

@implementation RDAppDelegate

@synthesize mainController;

- (void)dealloc {
	[preferencesController release];
	[super dealloc];
}

- (void)awakeFromNib {
	preferencesController = [[RDPrefsController alloc] init];
	//[[NSApplication sharedApplication] redirectConsoleLogToDocumentFolder];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (![_window setFrameUsingName:@"Main"]) {
		[_window center];
	}
	
	[mainController refresh];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	[_window makeKeyAndOrderFront:self];
    
    return YES;
}

#pragma mark -
#pragma mark IBAction
#pragma mark -

- (IBAction)preferences:(id)sender {
	[preferencesController showWindow:sender];
	[preferencesController refresh];
	[[preferencesController window] center];
}

@end
