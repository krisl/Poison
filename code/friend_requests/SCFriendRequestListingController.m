// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCFriendRequestListingController.h"
#import "SCTOXNetworkConnection.h"
#import "SCFriendListManager.h"
#import "SCRequestCellView.h"
#import "SCAppDelegate.h"

@interface SCFriendRequestListingController ()

@end

@implementation SCFriendRequestListingController {
    NSDateFormatter *formatter;
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.doesRelativeDateFormatting = YES;
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendRequests:) name:@"UpdateFriendRequestCount" object:[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager]];
    }
    return self;
}

- (IBAction)dismissWindow:(id)sender {
    [NSApp endSheet:self.window];
}

- (NSUInteger)numberOfRowsInListView:(PXListView *)aListView {
    return [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] pendingRequests].count;
}

- (CGFloat)listView:(PXListView *)aListView heightOfRow:(NSUInteger)row {
    return 77;
}

- (PXListViewCell *)listView:(PXListView *)aListView cellForRow:(NSUInteger)row {
    NSDictionary *thisRequest = [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] pendingRequests][row];
    SCRequestCellView *cell = nil;
    if (!(cell = (SCRequestCellView*)[aListView dequeueCellWithReusableIdentifier:@"FriendReqCell"])) {
        cell = [SCRequestCellView cellLoadedFromNibNamed:@"RequestCell" bundle:[NSBundle mainBundle] reusableIdentifier:@"FriendReqCell"];
    }
    cell.publicKey.stringValue = thisRequest[@"publicKey"];
    cell.dateReceived.stringValue = [formatter stringFromDate:thisRequest[@"timeReceived"]];
    return cell;
}

- (void)listViewSelectionDidChange:(NSNotification *)aNotification {
    self.trustCheck.state = NSOffState;
    [self.acceptButton setEnabled:NO];
    if ([self.listView selectedRow] < [self numberOfRowsInListView:self.listView]) {
        self.requestFormView.hidden = NO;
        [self.ignoreButton setEnabled:YES];
        NSDictionary *theRequest = [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] pendingRequests][[self.listView selectedRow]];
        self.openRequestPublicKey.stringValue = theRequest[@"publicKey"];
        self.openRequestTimestamp.stringValue = [formatter stringFromDate:theRequest[@"timeReceived"]];
        [self.messageView setString:theRequest[@"message"]];
    } else {
        self.requestFormView.hidden = YES;
        [self.ignoreButton setEnabled:NO];
    }
}

- (void)updateFriendRequests:(NSNotification *)notification {
    [self.listView reloadData];
}

- (IBAction)ignoreSelectedRequest:(id)sender {
    NSUInteger nowSelected = [self.listView selectedRow];
    NSDictionary *theRequest = [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] pendingRequests][[self.listView selectedRow]];
    NSString *theKey = theRequest[@"publicKey"];
    theRequest = nil;
    [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] removePendingFriendRequestWithPublicKey:theKey];
    if (![self numberOfRowsInListView:nil]) {
        [self.listView setSelectedRow:-1];
        [NSApp endSheet:self.window]; // if there are no more requests, we can close the sheet for them
    } else {
        [self.listView setSelectedRow:MAX(nowSelected, 1) - 1];
    }
}

- (IBAction)acceptSelectedRequest:(id)sender {
    NSUInteger nowSelected = [self.listView selectedRow];
    NSDictionary *theRequest = [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] pendingRequests][[self.listView selectedRow]];
    NSString *theKey = theRequest[@"publicKey"];
    [[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager] acceptPendingFriendRequestWithPublicKey:theKey];
    if (![self numberOfRowsInListView:nil]) {
        [self.listView setSelectedRow:-1];
        [NSApp endSheet:self.window]; // if there are no more requests, we can close the sheet for them
    } else {
        [self.listView setSelectedRow:MAX(nowSelected, 1) - 1];
    }
}

- (IBAction)trustStateChanged:(NSButton *)sender {
    [self.acceptButton setEnabled:sender.state == NSOnState ? YES : NO];
}

- (void)awakeFromNib {
    self.listView.delegate = self;
    [self.listView reloadData];
    [self.listView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

@end
