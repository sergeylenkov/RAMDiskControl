#import "PrefsWindow.h"

@implementation PrefsWindow

- (id)init {
    if (self = [super init]) {
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];    
    }
    
    return self;
}

- (void)keyDown:(NSEvent *) event {
    if ([event keyCode] == 53) {
        [self close];
	} else {
        [super keyDown: event];
	}
}

- (void)close {
    [self makeFirstResponder: nil];
    [super close];
}

@end
