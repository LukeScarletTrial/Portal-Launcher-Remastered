#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface PortalBrowserController : UIViewController <WKNavigationDelegate, WKDownloadDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation PortalBrowserController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Portal Library";
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://modrinth.com"]]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
}

- (void)webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navigationAction didBecomeDownload:(WKDownload *)download {
    download.delegate = self;
}

- (void)download:(WKDownload *)download decideDestinationUsingResponse:(NSURLResponse *)res suggestedFilename:(NSString *)name completionHandler:(void (^)(NSURL *))handler {
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *modsPath = [docs stringByAppendingPathComponent:@"minecraft/mods"];
    [[NSFileManager defaultManager] createDirectoryAtPath:modsPath withIntermediateDirectories:YES attributes:nil error:nil];
    handler([NSURL fileURLWithPath:[modsPath stringByAppendingPathComponent:name]]);
}

- (void)dismiss { [self dismissViewControllerAnimated:YES completion:nil]; }
@end
