//
//  PDFViewController.m
//  Viewer App
//
//  Created by Jayve Javier on 5/13/21.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@property (nonatomic, strong) IBOutlet WKWebView *webView;

@end

@implementation PDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Detail View";
    
    NSString *filePath;
    filePath = [[NSBundle mainBundle] pathForResource:self.data ofType:@"pdf"];

    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    
    [webView setBackgroundColor:[UIColor whiteColor]];
    
    [webView loadRequest:nsrequest];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:webView];
}


@end
