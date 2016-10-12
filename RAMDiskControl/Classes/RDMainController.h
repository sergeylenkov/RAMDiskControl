//
//  RDMainController.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 11.09.12.
//
//

#import <Foundation/Foundation.h>
#import "PXListView.h"
#import "RDNewDiskController.h"
#import "RDDiskCell.h"
#import "RDDiskManager.h"

@interface RDMainController : NSObject <PXListViewDelegate, RDDiskManagerDelegate> {
	RDNewDiskController *newDiskController;
	NSMutableArray *_disks;
	NSTimer *_autosaveTimer;
}

@property (nonatomic, assign) IBOutlet PXListView *listView;
@property (nonatomic, assign) IBOutlet NSSegmentedControl *runSegment;

- (void)refresh;
- (void)saveDisks;
- (void)unmountDisks;

- (IBAction)createDisk:(id)sender;
- (IBAction)mountDisk:(id)sender;
- (IBAction)saveDisk:(id)sender;
- (IBAction)restoreDisk:(id)sender;

@end
