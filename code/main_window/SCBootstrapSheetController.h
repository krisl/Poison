// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>

@interface SCBootstrapSheetController : NSWindowController

@property (strong) IBOutlet NSTextField *ipField;
@property (strong) IBOutlet NSTextField *portField;
@property (strong) IBOutlet NSTextField *keyField;
@property (strong) IBOutlet NSButton *rememberCheck;
@property (strong) IBOutlet NSTextField *addressLabel;
@property (strong) IBOutlet NSTextField *publicKeyLabel;

@end
