// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCAddFriendSheetController.h"
#import "SCPublicKeyFormatter.h"

@interface SCAddFriendSheetController ()

@end

@implementation SCAddFriendSheetController

- (void)awakeFromNib {
    self.keyField.formatter = [[SCPublicKeyFormatter alloc] init];
}

- (IBAction)cancelRequest:(id)sender {
    [NSApp endSheet:self.window];
}

@end
