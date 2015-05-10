//
//  GAWebViewController.m
//  BTC News
//
//  Created by tt on 14-1-14.
//  Copyright (c) 2014年 AnnyFun. All rights reserved.
//

#import "GAWebViewController.h"

@interface GAWebViewController ()<UIWebViewDelegate>
{
    UIWebView *webView;
}
@end

@implementation GAWebViewController

- (void)dealloc
{
    NSLog(@"GAWebViewController dealloc");
    [webView stopLoading];
    webView.delegate = nil;
    [webView removeFromSuperview];
    webView = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        webView.scalesPageToFit = YES;
        webView.delegate = self;
        [self.view addSubview:webView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)loadUrl:(NSString *)url{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)loadHtml:(NSString *)html baseUrlStr:(NSString *)baseURL{
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:baseURL]];
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{

    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

    if (error.code==-1009) {
        
    }
    else{
        
    }
}

@end
