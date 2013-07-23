// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCBootstrapSheetController.h"
#import "SCAppDelegate.h"
#import "SCTOXNetworkConnection.h"

@interface SCBootstrapSheetController ()

BOOL SCStringIsValidIPAddress(NSString *theString);

@end

@implementation SCBootstrapSheetController

- (IBAction)continueWithConnection:(id)sender {
    self.addressLabel.stringValue = NSLocalizedString(@"Enter the address of a server to bootstrap against.", @"");
    self.publicKeyLabel.stringValue = NSLocalizedString(@"The server's public key:", @"");
    NSHost *resolvedAddr = nil;
    if (!SCStringIsValidIPAddress(self.ipField.stringValue)) {
        resolvedAddr = [NSHost hostWithName:self.ipField.stringValue];
    } else {
        resolvedAddr = [NSHost hostWithAddress:self.ipField.stringValue];
    }
    if (![resolvedAddr address]) {
        self.addressLabel.stringValue = NSLocalizedString(@"That's not an IP address. Did you enter it correctly?", @"");
        return;
    }
    NSInteger port = [self.portField.stringValue integerValue];
    if (port < 1 || port > 65535) {
        self.addressLabel.stringValue = NSLocalizedString(@"That doesn't look right. Ports must be in the range 1-65535.", @"");
        return;
    }
    NSString *publicKey = [self.keyField stringValue];
    if (!SCPublicKeyIsValid(publicKey)) {
        self.publicKeyLabel.stringValue = NSLocalizedString(@"That doesn't look like a public key.", @"");
        return;
    }
    if (self.rememberCheck.state == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AutomaticallyBootstrap"];
        [[NSUserDefaults standardUserDefaults] setObject:self.ipField.stringValue forKey:@"BootstrapSavedServer"];
        [[NSUserDefaults standardUserDefaults] setInteger:port forKey:@"BootstrapSavedPort"];
        [[NSUserDefaults standardUserDefaults] setObject:publicKey forKey:@"BootstrapSavedKey"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutomaticallyBootstrap"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BootstrapSavedServer"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"BootstrapSavedPort"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"BootstrapSavedKey"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BootstrapInfoReceived" object:nil userInfo:@{@"address": [resolvedAddr address], @"port": @(port), @"publickey": publicKey}];
    [NSApp endSheet:self.window];
}

- (IBAction)cancel:(id)sender {
    [NSApp endSheet:self.window returnCode:-1];
}

@end
