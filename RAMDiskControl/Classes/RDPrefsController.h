#import <Cocoa/Cocoa.h>
#import "PTLoginItem.h"

@interface RDPrefsController : NSWindowController <NSToolbarDelegate> {
    IBOutlet NSView *generalView;
    IBOutlet NSButton *startAtLoginButton;
	IBOutlet NSButton *autosaveButton;
	IBOutlet NSTextField *autosaveField;
	IBOutlet NSButton *saveOnQuitButton;
	IBOutlet NSPopUpButton *pathButton;
	NSUserDefaults *defaults;
}

- (void)setPrefView:(id)sender;
- (void)refresh;
- (void)selectTabWithIndetifier:(NSString *)identifier;

- (IBAction)changeStartAtLogin:(id)sender;
- (IBAction)changeAutosave:(id)sender;
- (IBAction)changeAutosaveInterval:(id)sender;
- (IBAction)changeSaveOnQuit:(id)sender;
- (IBAction)changePath:(id)sender;

@end
