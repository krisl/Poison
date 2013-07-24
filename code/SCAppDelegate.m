// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCAppDelegate.h"
#import "SCWelcomeWindowController.h"
#import "SCMainChatWindowController.h"
#import "SCTOXNetworkConnection.h"
#import "SCPreferencesWindowController.h"
#import "SCAboutWindowController.h"
#import <AppKit/NSNibLoading.h>

@interface NSBundle ()
// for 10.6
- (BOOL)loadNibNamed:(NSString *)nibName owner:(id)owner;

@end

@implementation SCAppDelegate {
    SCAboutWindowController *aboutWindow;
    SCMainChatWindowController *chatWindow;
    SCWelcomeWindowController *welcomeWindow;
    NSString *friendRequestString;
    SCPreferencesWindowController *prefsWindow;
    BOOL isConnected;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
        NSLog(@"will forget stuff");
        self.shouldForgetEverything = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seriouslyConnectToTOX:) name:@"BootstrapInfoReceived" object:nil];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutomaticallyConnectWithSavedUsername"] && [[NSUserDefaults standardUserDefaults] stringForKey:@"AutoconnectSavedUsername"] && !self.shouldForgetEverything) {
        chatWindow = [[SCMainChatWindowController alloc] initWithWindowNibName:@"MainWindow"];
        [chatWindow showWindow:self];
        self.nickname = [[NSUserDefaults standardUserDefaults] stringForKey:@"AutoconnectSavedUsername"];
    } else {
        welcomeWindow = [[SCWelcomeWindowController alloc] initWithWindowNibName:@"LoginWindow"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveConnectNotification:) name:@"ShouldConnect" object:welcomeWindow];
        [welcomeWindow showWindow:self];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (chatWindow) {
        [chatWindow showWindow:self];
    } else if (welcomeWindow) {
        [welcomeWindow showWindow:self];
    }
    return YES;
}

#pragma mark - Notifications

- (void)didReceiveConnectNotification:(NSNotification*)notification {
    [welcomeWindow close];
    welcomeWindow = nil;
    self.nickname = [notification userInfo][@"nickname"];
    chatWindow = [[SCMainChatWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [chatWindow showWindow:self];
    NSLog(@"Should connect with username: %@", [notification userInfo][@"nickname"]);
}

- (void)seriouslyConnectToTOX:(NSNotification*)notification {
    if (!self.connection)
        [self connectTOXWithBootstrapAddress:notification.userInfo[@"address"] port:[notification.userInfo[@"port"] integerValue] publicKey:notification.userInfo[@"publickey"]];
    else NSLog(@"connection is not nil, not connecting again");
}

- (void)killConnection:(NSNotification*)notification {
    isConnected = NO;
    [self.connection disconnect];
    self.connection = nil;
}

- (void)didConnectSuccessfully:(NSNotification*)notification {
    isConnected = YES;
    [[chatWindow window] setTitle:[NSString stringWithFormat:@"%@: %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleName"], NSLocalizedString(@"Connected!", @"")]];
}

#pragma mark - Outsde Event Handlers

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"%@", url);
}

- (BOOL)application:(NSApplication*)app openFile:(NSString *)filename {
    NSLog(@"Opening file %@", filename);
    return YES;
}

- (void)handleOpenDocumentEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"%@", url);
}

#pragma mark - Connection

- (void)connectTOXWithBootstrapAddress:(NSString*)theAddress port:(NSInteger)thePort publicKey:(NSString *)theKey {
    self.connection = [[SCTOXNetworkConnection alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killConnection:) name:@"BootstrapDidFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectSuccessfully:) name:@"BootstrapDidComplete" object:nil];
    [self.connection connectWithNickname:self.nickname address:theAddress port:thePort publicKey:(NSString *)theKey];
}

#pragma mark - Menubar Actions

- (IBAction)showAboutWindow:(id)sender {
    if (!aboutWindow) {
        aboutWindow = [[SCAboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];
    }
    [aboutWindow showWindow:self];
}

- (IBAction)showPreferencesWindow:(id)sender {
    if (!prefsWindow) {
        prefsWindow = [[SCPreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
    }
    [prefsWindow showWindow:self];
}

- (IBAction)copyPublicKey:(id)sender {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[self.connection.publicKey]];
}

- (IBAction)proxyAddFriend:(id)sender {
    if (isConnected) {
        [chatWindow showAddFriendModal];
    }
}

- (void)dealloc {
    chatWindow = nil;
    welcomeWindow = nil;
    aboutWindow = nil;
    prefsWindow = nil;
}

@end
