#import "RDPrefsController.h"

#define TOOLBAR_GENERAL @"TOOLBAR_GENERAL"

@implementation RDPrefsController

- (id)init {
    self = [super initWithWindowNibName:@"PrefsWindow"];
    
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib {    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"Preferences Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    [toolbar setSelectedItemIdentifier:TOOLBAR_GENERAL];
    [[self window] setToolbar:toolbar];
    [toolbar release];

	[[self window] center];
    
	[self setPrefView:nil];
}

- (void)refresh {
    startAtLoginButton.state = [PTLoginItem willStartAtLogin:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	autosaveButton.state = [RDSettings sharedSettings].autosave;
	autosaveField.enabled = [RDSettings sharedSettings].autosave;
	autosaveField.integerValue = [RDSettings sharedSettings].autosaveInterval;
	saveOnQuitButton.state = [RDSettings sharedSettings].saveOnQuit;
	
	NSString *folder = [RDSettings sharedSettings].savePath;
	NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:folder];
	[iconImage setSize:NSMakeSize(16, 16)];
	
	[[pathButton itemAtIndex:0] setImage:iconImage];
	[[pathButton itemAtIndex:0] setTitle:[folder lastPathComponent]];
	[pathButton selectItemAtIndex:0];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)ident willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:ident];

    if ([ident isEqualToString:TOOLBAR_GENERAL]) {
        [item setLabel:@"General"];
        [item setImage:[NSImage imageNamed:@"NSPreferencesGeneral"]];
        [item setTarget:self];
        [item setAction:@selector(setPrefView:)];
        [item setAutovalidates:NO];
    } else {
        [item release];
        return nil;
    }

    return [item autorelease];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:TOOLBAR_GENERAL, nil];
}

- (void)setPrefView:(id)sender {
	NSString *identifier = TOOLBAR_GENERAL;
	NSView *view = generalView;
        
    [[[self window] toolbar] setSelectedItemIdentifier:identifier];
    
    NSWindow *window = [self window];
	
    if ([window contentView] == view) {
        return;
    }

    NSRect windowRect = [window frame];
    float difference = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
   
	difference = ([view frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    windowRect.size.width += difference;
	
    [view setHidden:YES];
    [window setContentView:view];
    [window setFrame:windowRect display:YES animate:YES];
    [view setHidden:NO];
    
    if (sender) {
        [window setTitle:[sender label]];
    } else {
        NSToolbar *toolbar = [window toolbar];
        NSString *itemIdentifier = [toolbar selectedItemIdentifier];
        NSEnumerator *enumerator = [[toolbar items] objectEnumerator];
        NSToolbarItem *item;
		
        while ((item = [enumerator nextObject])) {
            if ([[item itemIdentifier] isEqualToString:itemIdentifier]) {
                [window setTitle:[item label]];
                break;
            }
		}
    }
}

- (void)selectTabWithIndetifier:(NSString *)identifier {
	NSView *view;
	
	identifier = TOOLBAR_GENERAL;
	view = generalView;
        
    [[[self window] toolbar] setSelectedItemIdentifier:identifier];
    
    NSWindow *window = [self window];
	
    if ([window contentView] == view) {
        return;
    }
	
    NSRect windowRect = [window frame];
    float difference = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
	
	difference = ([view frame].size.width - [[window contentView] frame].size.width) * [window userSpaceScaleFactor];
    windowRect.size.width += difference;
	
    [view setHidden:YES];
    [window setContentView:view];
    [window setFrame:windowRect display:YES animate:YES];
    [view setHidden:NO];
    
	NSToolbar *toolbar = [window toolbar];
	NSString *itemIdentifier = [toolbar selectedItemIdentifier];
	NSEnumerator *enumerator = [[toolbar items] objectEnumerator];
	NSToolbarItem *item;
    
	while ((item = [enumerator nextObject])) {
		if ([[item itemIdentifier] isEqualToString:itemIdentifier]) {
			[window setTitle:[item label]];
			break;
		}
	}
}

- (IBAction)changeStartAtLogin:(id)sender {
    [PTLoginItem setStartAtLogin:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] enabled:startAtLoginButton.state];
}

- (IBAction)changeAutosave:(id)sender {
	[RDSettings sharedSettings].autosave = autosaveButton.state;
	
	if ([RDSettings sharedSettings].autosave) {
		autosaveField.enabled = YES;
	} else {
		autosaveField.enabled = NO;
	}
}

- (IBAction)changeAutosaveInterval:(id)sender {
	[RDSettings sharedSettings].autosaveInterval = autosaveField.integerValue;
}

- (IBAction)changeSaveOnQuit:(id)sender {
	[RDSettings sharedSettings].saveOnQuit = saveOnQuitButton.state;
}

- (IBAction)changePath:(id)sender {
	if ([pathButton indexOfSelectedItem] == 2) {
		NSOpenPanel *panel = [NSOpenPanel openPanel];
		
		[panel setPrompt:@""];
		[panel setAllowsMultipleSelection:NO];
		[panel setCanChooseFiles:NO];
		[panel setCanChooseDirectories:YES];
		[panel setCanCreateDirectories:YES];
		
        [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton) {
                NSString *folder = [[[panel URLs] objectAtIndex:0] path];
                
				[RDSettings sharedSettings].savePath = folder;
                
                NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:folder];
                [iconImage setSize:NSMakeSize(16, 16)];
                
                [[pathButton itemAtIndex:0] setImage:iconImage];
                [[pathButton itemAtIndex:0] setTitle:[[RDSettings sharedSettings].savePath lastPathComponent]];
                [pathButton selectItemAtIndex:0];
            }
        }];
	}
}

@end
