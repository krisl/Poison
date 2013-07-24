// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCAppDelegate.h"
#import "SCMainChatWindowController.h"
#import "SCTOXNetworkConnection.h"
#import "SCChatBaseBackgroundView.h"
#import "SCAddFriendSheetController.h"
#import "SCBootstrapSheetController.h"
#import "SCConversationViewController.h"
#import "SCConversationWindowController.h"
#import "SCFriendRequestListingController.h"
#import "SCChromeBGView.h"
#import "PXListView.h"
#import "SCFriendListManager.h"
#import "SCChatContext.h"
#include <arpa/inet.h>

@interface SCMainChatWindowController ()

@end

@implementation SCMainChatWindowController {
    NSWindowController *sheetContext;
    SCConversationViewController *chatView;
    NSMutableArray *openConversationWindows;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    //[self.window setFrame:(NSRect){self.window.frame.origin, {200, self.window.frame.size.height}}display:NO animate:NO];
    self.window.delegate = self;
    self.splitView.delegate = self;
    openConversationWindows = [@[] mutableCopy];
    SCAppDelegate *appDelegate = [NSApp delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bootstrappingDidFail:) name:@"BootstrapDidFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setStatusOnline:) name:@"BootstrapDidComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setStatusOffline:) name:@"NetworkDidDisconnect" object:appDelegate.connection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFriendAtCellIndex:) name:@"DeleteFriendAtCellIndex" object:nil];
    
    //self.backgroundView.backgroundColor = [NSColor colorWithCalibratedRed:0.8824 green:0.8980 blue:0.9294 alpha:1.0000];
}

#pragma mark - Notifications

- (void)setStatusOnline:(NSNotification*)notification {
    self.nicknameField.stringValue = ((SCAppDelegate*)[NSApp delegate]).nickname;
    [self.nicknameField setToolTip:[[(SCAppDelegate*)[NSApp delegate] connection] publicKey]];
    self.statusField.stringValue = NSLocalizedString(@"Online", @"");
    self.friendsList.delegate = [[(SCAppDelegate*)[NSApp delegate] connection] friendsManager];
    [self.friendsList reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendRequestCount:) name:@"UpdateFriendRequestCount" object:[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needToUpdateFriendList:) name:@"UpdateFriendListView" object:[[(SCAppDelegate*)[NSApp delegate] connection] friendsManager]];
    chatView = [[SCConversationViewController alloc] initWithNibName:@"Conversation" bundle:[NSBundle mainBundle]];
    [chatView loadView];
    chatView.bottomBar.roundsLeftCorner = NO;
    chatView.bottomBar.roundsRightCorner = YES;
    //[self.window setFrame:(NSRect){self.window.frame.origin, {self.window.frame.size.width + 500, self.window.frame.size.height}} display:NO animate:YES];
    [self.splitView addSubview:chatView.view];
    [self.sidebar setFrameSize:(NSSize){200, self.sidebar.frame.size.height}];
    //[self forkNewConversationWindow:nil];
}

- (void)setStatusOffline:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusField.stringValue = NSLocalizedString(@"Offline", @"");
    });
}

- (void)updateFriendRequestCount:(NSNotification *)notification {
    [self.friendRequestsCount setStringValue:[NSString stringWithFormat:@"%lli", [notification.userInfo[@"newCount"] longLongValue]]];
}

- (void)needToUpdateFriendList:(NSNotification *)notification {
    [self.friendsList reloadData];
}

- (void)bootstrappingDidFail:(NSNotification*)notification {
    sheetContext = [[SCBootstrapSheetController alloc] initWithWindowNibName:@"BootstrapSheet"];
    [sheetContext loadWindow];
    ((SCBootstrapSheetController*)sheetContext).addressLabel.stringValue = NSLocalizedString(@"Bootstrapping failed. Please try another server.", @"");
    [NSApp beginSheet:sheetContext.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)deleteFriendAtCellIndex:(NSNotification *)notification {
    
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSLog(@"didEndSheet");
    [sheet orderOut:self];
    sheetContext = nil;
    if (returnCode == -1) {
        [NSApp terminate:nil];
    }
}

- (void)shouldForkNewWindow:(NSNotification *)notification {
    [self forkNewConversationWindow:nil];
}

#pragma mark - Actions

- (IBAction)addFriendWasPressed:(id)sender {
    [self showAddFriendModal];
}

- (void)showAddFriendModal {
    sheetContext = [[SCAddFriendSheetController alloc] initWithWindowNibName:@"AddFriend"];
    [sheetContext loadWindow];
    [NSApp beginSheet:sheetContext.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)forkNewConversationWindow:(id)unused {
    SCConversationWindowController *newWindow = [[SCConversationWindowController alloc] initWithWindow:[[NSWindow alloc] initWithContentRect:(NSRect){self.window.frame.origin, {513, 503}} styleMask:15 backing:NSBackingStoreBuffered defer:YES] chatContext:[[SCChatContext alloc] init]];
    [openConversationWindows addObject:newWindow];
    [newWindow showWindow:self];
}

- (IBAction)showFriendRequestsSheet:(id)sender {
    if (!sheetContext) {
        sheetContext = [[SCFriendRequestListingController alloc] initWithWindowNibName:@"RequestsList"];
        [sheetContext loadWindow];
        [NSApp beginSheet:sheetContext.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
    }
}

#pragma mark - NSWindow Delegate

BOOL SCStringIsValidIPAddress(NSString *theString) {
    const char *utf8 = [theString UTF8String];
    int success = 0;
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    return (success == 1 ? YES : NO);
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    self.window.delegate = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldForkNewWindow:) name:@"FriendCellDoubleClick" object:nil];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutomaticallyBootstrap"] && ![(SCAppDelegate*)[NSApp delegate] shouldForgetEverything]) {
        NSString *savedIP = [[NSUserDefaults standardUserDefaults] stringForKey:@"BootstrapSavedServer"];
        NSInteger savedPort = [[NSUserDefaults standardUserDefaults] integerForKey:@"BootstrapSavedPort"];
        NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"BootstrapSavedKey"];
        if (savedPort > 0 && savedPort < 65535 && [savedKey length] == 64) {
            NSHost *resolvedAddr = nil;
            if (!SCStringIsValidIPAddress(savedIP)) {
                resolvedAddr = [NSHost hostWithName:savedIP];
            } else {
                resolvedAddr = [NSHost hostWithAddress:savedIP];
            }
            NSLog(@"Resolved %@ to %@...", savedIP, [resolvedAddr address]);
            if ([resolvedAddr address]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BootstrapInfoReceived" object:nil userInfo:@{@"address": [resolvedAddr address], @"port": @(savedPort), @"publickey": savedKey}];
                return;
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BootstrapSavedServer"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"BootstrapSavedPort"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BootstrapSavedKey"];
    }
    sheetContext = [[SCBootstrapSheetController alloc] initWithWindowNibName:@"BootstrapSheet"];
    [sheetContext loadWindow];
    [NSApp beginSheet:sheetContext.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
}

#pragma mark - NSSplitView delegate

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    if (subview == [splitView subviews][0]) {
        return YES;
    } else return NO;
}
//        [self connectTOX];

- (void)dealloc {
    sheetContext = nil;
    openConversationWindows = nil;
}

@end
