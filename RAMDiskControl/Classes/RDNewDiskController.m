//
//  RDNewDiskController.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import "RDNewDiskController.h"

@implementation RDNewDiskController

@synthesize nameField;
@synthesize sizeField;
@synthesize mountButton;
@synthesize saveButton;
@synthesize disk = _disk;

- (void)setDisk:(RDDisk *)aDisk {
	[_disk release];
	_disk = [aDisk retain];
	
	nameField.stringValue = _disk.name;
	sizeField.stringValue = [NSString stringWithFormat:@"%ld", _disk.size / (1024 * 1000)];
	mountButton.state = _disk.autoMount;
	
	saveButton.title = @"Save";
}

#pragma mark -
#pragma mark IBAction
#pragma mark -

- (IBAction)create:(id)sender {
	NSUInteger size = sizeField.integerValue * 1024 * 1000;
	
	if (!self.disk) {
		if ([[RDSettings sharedSettings] isDiskExists:nameField.stringValue]) {
			NSString *text = [NSString stringWithFormat:@"Disk with name \"%@\" exists.", nameField.stringValue];
			
			NSAlert *alert = [NSAlert alertWithMessageText:text defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
			[alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
			
			return;
		}

		RDDiskManager *manager = [RDDiskManager sharedManager];
		[manager createDisk:nameField.stringValue size:size autoMount:mountButton.state];
	} else {
		_disk.name = nameField.stringValue;
		_disk.size = size;
		_disk.autoMount = mountButton.state;
		
		[[RDSettings sharedSettings] saveDisk:_disk];
	}
	
	[self cancel:nil];
}

- (IBAction)cancel:(id)sender {
	[self close];
    [NSApp endSheet:self.window];
    [self.window orderOut:self];
}

@end
