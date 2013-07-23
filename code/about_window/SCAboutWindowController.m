// You will not find the licensing jibber-jabber here.
// Go read it elsewhere.

#import "SCAboutWindowController.h"

@implementation SCAboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.versionString.stringValue = [NSString stringWithFormat:@"%@ %@", [NSBundle mainBundle].infoDictionary[@"CFBundleName"], [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
}

#pragma mark - About Window actions

- (IBAction)visitTOXWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://tox.im/"]];
}

- (IBAction)visitGithubPage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/stal888/Poison"]];
}

@end
