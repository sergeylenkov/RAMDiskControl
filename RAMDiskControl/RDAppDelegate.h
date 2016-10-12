//
//  RDAppDelegate.h
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import <Cocoa/Cocoa.h>
#import "RDMainController.h"
#import "RDPrefsController.h"

@interface RDAppDelegate : NSObject <NSApplicationDelegate> {
	RDPrefsController *preferencesController;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet RDMainController *mainController;

- (IBAction)preferences:(id)sender;

@end
