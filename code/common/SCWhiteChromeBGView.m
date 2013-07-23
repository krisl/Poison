// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCWhiteChromeBGView.h"

@implementation SCWhiteChromeBGView

- (NSGradient *)chromeForState {
    NSGradient *chrome = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor colorWithCalibratedWhite:232.0 / 255.0 alpha:1.0]];
    return chrome;
}

- (NSColor *)shadowColour {
    return [NSColor colorWithCalibratedWhite:1.0 alpha:0.8];
}

@end
