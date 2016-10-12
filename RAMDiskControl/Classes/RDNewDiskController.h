//
//  RDNewDiskController.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import <Foundation/Foundation.h>
#import "RDDiskManager.h"

@interface RDNewDiskController : NSWindowController {
	RDDisk *_disk;
}

@property (nonatomic, assign) IBOutlet NSTextField *nameField;
@property (nonatomic, assign) IBOutlet NSTextField *sizeField;
@property (nonatomic, assign) IBOutlet NSButton *mountButton;
@property (nonatomic, assign) IBOutlet NSButton *saveButton;
@property (nonatomic, retain) RDDisk *disk;

- (IBAction)create:(id)sender;
- (IBAction)cancel:(id)sender;

@end
