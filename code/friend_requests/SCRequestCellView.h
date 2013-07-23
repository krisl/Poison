// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"

@interface SCRequestCellView : PXListViewCell

@property (strong) IBOutlet NSTextField *publicKey;
@property (strong) IBOutlet NSTextField *dateReceived;

@end
