//
//  RDDiskCell.m
//  RAMDiskControl
//
//  Created by Sergey Lenkov on 10.09.12.
//
//

#import "RDDiskCell.h"

@implementation RDDiskCell

@synthesize name;
@synthesize disk;
@synthesize size;
@synthesize freeSize;
@synthesize buttonAction;
@synthesize buttonTarget;
@synthesize isMounted;

- (void)dealloc {
    [name release];
    [disk release];
    [size release];
    [button release];
    
    [self removeTrackingArea:trackingArea];
    [trackingArea release];
    
    [super dealloc];
}

- (id)initWithReusableIdentifier:(NSString *)identifier {
    self = [super initWithReusableIdentifier:identifier];
    
    if (self) {
        self.name = @"";
        self.disk = @"";
        self.size = @"";
		self.isMounted = NO;
		
        button = [[NSButton alloc] initWithFrame:NSMakeRect(self.frame.size.width - 24, 22, 18, 18)];
        [button setBordered:NO];
        [button setTitle:@""];
        [button setButtonType:NSMomentaryChangeButton];
        [button setImage:[NSImage imageNamed:@"sl-icon-small_trash-eject"]];
        [button setAlternateImage:[NSImage imageNamed:@"sl-icon-small_trash-eject"]];
        [button setHidden:YES];
        [button setAction:@selector(buttonPressed)];
        [button setTarget:self];
        
        [self addSubview:button];
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self removeTrackingArea:trackingArea];
    [trackingArea release];
    
    NSTrackingAreaOptions trackingOptions =	NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp;
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:trackingOptions owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.isSelected) {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:200.0/255.0 green:207.0/255.0 blue:221.0/255.0 alpha:1.0] 
                                                             endingColor:[NSColor colorWithDeviceRed:179.0/255.0 green:188.0/255.0 blue:203.0/255.0 alpha:1.0]];
        [gradient drawInRect:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height) angle:90];
        [gradient release];
    } else {
		[[NSColor colorWithDeviceRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0] set];

        NSRectFill(NSMakeRect(0, 0, self.frame.size.width + 3, self.frame.size.height + 2));
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSLeftTextAlignment];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:@"Helvetica" traits:NSBoldFontMask weight:0 size:14];
    
    NSDictionary *attsDict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,
                                                                        paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    [paragraphStyle release];
    
    [self.name drawInRect:NSMakeRect(10, 12, self.frame.size.width - 40, 18) withAttributes:attsDict];
	
	attsDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName, nil];
	
	NSString *_size = size;
	
	if (isMounted) {
		_size = [NSString stringWithFormat:@"%@, %@ free", size, freeSize];
	}
	
    [_size drawInRect:NSMakeRect(10, 32, self.frame.size.width - 40, 18) withAttributes:attsDict];
	
    if (isMounted) {
        [button setFrame:NSMakeRect(self.frame.size.width - 28, 22, 18, 18)];
        [button setHidden:NO];
    } else {
        [button setHidden:YES];
    }
}

- (BOOL)isFlipped {
    return YES;
}

- (void)mouseEntered:(NSEvent *)theEvent {
    _isMouseOver = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    _isMouseOver = NO;
    [self setNeedsDisplay:YES];
}

- (void)buttonPressed {
    if (buttonTarget && [buttonTarget respondsToSelector:buttonAction]) {
        [buttonTarget performSelector:buttonAction withObject:self];
    }
}

@end
