// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>

@interface SCWelcomeWindowController : NSWindowController

@property (strong) IBOutlet NSTextField *helpfulLabel;
@property (strong) IBOutlet NSTextField *nameField;
@property (strong) IBOutlet NSButton *goButton;
@property (strong) IBOutlet NSButton *rememberCheck;
@property (strong) IBOutlet NSButton *webLinkButton;
@property (strong) IBOutlet NSTextField *versionLabel;

@end
