// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCWelcomeWindowController.h"

@interface SCWelcomeWindowController ()

@end

@implementation SCWelcomeWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleName"], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]]];
    [[self.nameField.cell fieldEditorForView:self.nameField] setInsertionPointColor:[NSColor whiteColor]];
}

- (IBAction)returnPressed:(id)sender {
    [self submitConnection:sender];
}

- (IBAction)submitConnection:(id)sender {
    NSString *nickname = [self.nameField stringValue];
    if ([[nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.nameField setStringValue:@""];
        [(NSTextFieldCell*)self.nameField.cell setPlaceholderString:NSLocalizedString(@"Your nickname cannot be blank.", @"")];
        //[self.nameField setPlace:NSLocalizedString(@"Your nickname cannot be blank.", @"")];
    } else {
        if ([self.rememberCheck state] == NSOnState) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AutomaticallyConnectWithSavedUsername"];
            [[NSUserDefaults standardUserDefaults] setValue:nickname forKey:@"AutoconnectSavedUsername"];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutomaticallyConnectWithSavedUsername"];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"AutoconnectSavedUsername"];
        }
        [(NSTextFieldCell*)self.nameField.cell setPlaceholderString:NSLocalizedString(@"Please wait...", @"")];
        [self.nameField setStringValue:@""];
        [self.nameField setEnabled:NO];
        [self.goButton setEnabled:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShouldConnect" object:self userInfo:@{@"nickname": nickname}];
    }
}

- (IBAction)siteButtonPressed:(NSButton *)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://projecttox.org/"]];
}

@end
