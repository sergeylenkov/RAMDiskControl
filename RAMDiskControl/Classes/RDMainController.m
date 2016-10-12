//
//  RDMainController.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 11.09.12.
//
//

#import "RDMainController.h"

@implementation RDMainController

@synthesize listView;
@synthesize runSegment;

- (void)dealloc {
	[newDiskController release];
	[_disks release];
    [super dealloc];
}

- (void)awakeFromNib {
	NSImage *image = [NSImage imageNamed:@"Eject"];
	[image setTemplate:YES];
	
	[runSegment setImage:image forSegment:1];
	
	newDiskController = [[RDNewDiskController alloc] initWithWindowNibName:@"NewDiskWindow"];
	[newDiskController loadWindow];
	
	[RDDiskManager sharedManager].delegate = self;
	_disks = [[NSMutableArray alloc] init];
	
	[_disks addObjectsFromArray:[[RDSettings sharedSettings] loadDisks]];
	
	if ([RDSettings sharedSettings].autosave) {
		_autosaveTimer = [[NSTimer scheduledTimerWithTimeInterval:[RDSettings sharedSettings].autosaveInterval * 60 target:self selector:@selector(autosave) userInfo:nil repeats:YES] retain];
	}
	
	[self refresh];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDisks) name:NSApplicationWillTerminateNotification object:nil];
	[NSThread detachNewThreadSelector:@selector(autoMountDisks) toTarget:self withObject:nil];
}

- (void)refresh {
	NSInteger selectedIndex = listView.selectedRow;
	
	[listView reloadData];
	
	if (selectedIndex != -1) {
		if (selectedIndex < [_disks count]) {
			listView.selectedRow = selectedIndex;
		} else {
			listView.selectedRow = 0;
		}
	}
}

- (void)autoMountDisks {
	for (RDDisk *disk in _disks) {
		if (disk.autoMount) {
			[[RDDiskManager sharedManager] mountDisk:disk error:nil];
			[[RDDiskManager sharedManager] restoreDisk:disk];
		}
	}
}

- (void)autosave {
	[NSThread detachNewThreadSelector:@selector(saveDiskThread) toTarget:self withObject:nil];
}

- (void)saveDiskThread {
	for (RDDisk *disk in _disks) {
		[[RDDiskManager sharedManager] saveDisk:disk];
	}
}

- (void)saveDisks {
	if ([RDSettings sharedSettings].saveOnQuit) {
		for (RDDisk *disk in _disks) {
			[[RDDiskManager sharedManager] saveDisk:disk];
		}
	}
	
	[self unmountDisks];
}

- (void)unmountDisks {
	for (RDDisk *disk in _disks) {
		if (disk.isMounted) {
			[[RDDiskManager sharedManager] unmountDisk:disk];
		}
	}
}

#pragma mark -
#pragma mark PXListViewDelegate
#pragma mark -

- (NSUInteger)numberOfRowsInListView: (PXListView*)aListView {
	return [_disks count];
}

- (PXListViewCell*)listView:(PXListView *)aListView cellForRow:(NSUInteger)row {
	RDDisk *disk = [_disks objectAtIndex:row];
	
	RDDiskCell *cell = (RDDiskCell *)[aListView dequeueCellWithReusableIdentifier:@"ID"];
        
	if (!cell) {
		cell = [[RDDiskCell alloc] initWithReusableIdentifier:@"ID"];
	}
        
	cell.buttonTarget = self;
	cell.buttonAction = @selector(cellButtonPressed:);

	cell.name = disk.name;
	cell.disk = disk.disk;
	cell.size = [[NSNumber numberWithInteger:disk.size] byte1000Representation];
    cell.isMounted = disk.isMounted;
	
	if (disk.isMounted) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		NSDictionary *attr = [fm attributesOfFileSystemForPath:[NSString stringWithFormat:@"/Volumes/%@", disk.name] error:&error];
		
		if (!error) {
			NSUInteger size = [[attr objectForKey:@"NSFileSystemSize"] integerValue];
			cell.size = [[NSNumber numberWithInteger:size] byte1000Representation];
			
			size = [[attr objectForKey:@"NSFileSystemFreeSize"] integerValue];
			cell.freeSize = [[NSNumber numberWithInteger:size] byte1000Representation];
		}
	}

	return cell;
}

- (CGFloat)listView:(PXListView *)aListView heightOfRow:(NSUInteger)row {
	return 60;
}

- (void)listViewSelectionDidChange:(NSNotification *)aNotification {
    //[self refresh];
}

- (void)listView:(PXListView *)aListView rowDoubleClicked:(NSUInteger)rowIndex {
	if (listView.selectedRow != -1) {
		RDDisk *disk = [_disks objectAtIndex:listView.selectedRow];
		
		newDiskController.disk = disk;
		[NSApp beginSheet:newDiskController.window modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
}

- (void)menuWillOpen:(NSMenu *)menu {
	BOOL isDiskSelected = NO;
	
	if (listView.selectedRow != -1) {
		RDDisk *disk = [_disks objectAtIndex:listView.selectedRow];
		isDiskSelected = disk.isMounted;
	}
	
	for (NSMenuItem *item in menu.itemArray) {
		[item setEnabled:isDiskSelected];
	}
}

#pragma mark -
#pragma mark RDDiskManagerDelegate
#pragma mark -

- (void)diskManager:(RDDiskManager *)manager didCreatedDisk:(RDDisk *)disk {
	[_disks addObject:disk];
	
	if (disk.autoMount) {
		NSError *error = nil;
		[[RDDiskManager sharedManager] mountDisk:disk error:&error];
	}
	
	[[RDSettings sharedSettings] saveDisk:disk];
	
	[self refresh];
}

- (void)diskManager:(RDDiskManager *)manager didRemovedDisk:(RDDisk *)disk {
	[self refresh];
}

- (void)diskManager:(RDDiskManager *)manager didMountedDisk:(RDDisk *)disk {
	[self refresh];
}

- (void)diskManager:(RDDiskManager *)manager didUnmountedDisk:(RDDisk *)disk {
	[self refresh];
}

#pragma mark -
#pragma mark IBAction
#pragma mark -

- (IBAction)createDisk:(id)sender {
	NSSegmentedControl *segment = (NSSegmentedControl *)sender;
	
	if (segment.selectedSegment == 0) {
		[NSApp beginSheet:newDiskController.window modalForWindow:[[NSApp delegate] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	} else {
		if (listView.selectedRow != -1) {
			RDDisk *disk = [_disks objectAtIndex:listView.selectedRow];

			if (disk.isMounted) {
				[[RDDiskManager sharedManager] unmountDisk:disk];
			}
			
			[[RDSettings sharedSettings] removeDisk:disk];
			[_disks removeObject:disk];
			
			[self refresh];
		}
	}
}

- (IBAction)mountDisk:(id)sender {
	NSSegmentedControl *segment = (NSSegmentedControl *)sender;
	
	if (listView.selectedRow != -1) {
		RDDisk *disk = [_disks objectAtIndex:listView.selectedRow];
		
		if (segment.selectedSegment == 0) {
			NSError *error = nil;
			[[RDDiskManager sharedManager] mountDisk:disk error:&error];
		} else {
			[[RDDiskManager sharedManager] unmountDisk:disk];
		}
	}
}

- (IBAction)cellButtonPressed:(id)sender {
	RDDiskCell *cell = (RDDiskCell *)sender;
    RDDisk *disk = [_disks objectAtIndex:cell.row];

	[[RDDiskManager sharedManager] unmountDisk:disk];
}

- (IBAction)saveDisk:(id)sender {
	if (listView.selectedRow != -1) {
		RDDisk *disk = [_disks objectAtIndex:listView.selectedRow];
		
		if (disk.isMounted) {
			[[RDDiskManager sharedManager] saveDisk:disk];
			
			[self refresh];
		}
	}
}

- (IBAction)restoreDisk:(id)sender {
	if (listView.selectedRow != -1) {
		RDDisk *disk = [_disks objectAtIndex:listView.selectedRow];
		
		if (disk.isMounted) {
			[[RDDiskManager sharedManager] restoreDisk:disk];
			
			[self refresh];
		}
	}
}

@end
