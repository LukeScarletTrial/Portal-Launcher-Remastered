#!/bin/bash
PLIST_PATH="./Amethyst-iOS/Natives/Info.plist"
LMV_PATH="./Amethyst-iOS/Natives/LauncherMenuViewController.m"

# 1. Branding & JIT Bypass
sed -i '' '/CFBundleDisplayName/{n;s/<string>.*<\/string>/<string>Portal<\/string>/;}' "$PLIST_PATH"
sed -i '' 's/org.angelauramc.amethyst/com.portalmc.portal/g' "$PLIST_PATH"
sed -i '' '/AltJIT/,+1d' "$PLIST_PATH"
sed -i '' 's/<key>LDEntitlements<\/key>/<key>PortalJITSkip<\/key>/g' "$PLIST_PATH"

# 2. Add WebKit Header
sed -i '' '1i\'$'\n''#import <WebKit/WebKit.h>'$'\n' "$LMV_PATH"

# 3. Append the Library Controller
cat << 'EOF' >> "$LMV_PATH"
@interface PortalBrowserController : UIViewController <WKNavigationDelegate, WKDownloadDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end
@implementation PortalBrowserController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Portal Library";
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [(WKWebView *)self.webView setNavigationDelegate:self];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://modrinth.com"]]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
}
- (void)webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navAction didBecomeDownload:(WKDownload *)download {
    download.delegate = self;
}
- (void)download:(WKDownload *)download decideDestinationUsingResponse:(NSURLResponse *)res suggestedFilename:(NSString *)name completionHandler:(void (^)(NSURL *))handler {
    NSString *modsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"minecraft/mods"];
    [[NSFileManager defaultManager] createDirectoryAtPath:modsPath withIntermediateDirectories:YES attributes:nil error:nil];
    handler([NSURL fileURLWithPath:[modsPath stringByAppendingPathComponent:name]]);
}
- (void)dismiss { [self dismissViewControllerAnimated:YES completion:nil]; }
@end
EOF

# 4. Link the Button
sed -i '' 's/enterModInstaller/openPortalLibrary/g' "$LMV_PATH"
sed -i '' '/@implementation LauncherMenuViewController/a \
- (void)openPortalLibrary { \
  PortalBrowserController *pbc = [[PortalBrowserController alloc] init]; \
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pbc]; \
  [self presentViewController:nav animated:YES completion:nil]; \
}' "$LMV_PATH"
