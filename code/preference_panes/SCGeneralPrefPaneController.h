// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>

@interface SCGeneralPrefPaneController : NSViewController

@property (strong) IBOutlet NSButton *autosaveCheck;
@property (strong) IBOutlet NSButton *updateCheck;
@property (strong) IBOutlet NSPopUpButton *updateFrequency;
@property (strong) IBOutlet NSButton *handleToxLinksCheck;

@end
