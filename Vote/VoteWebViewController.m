//
//  VoteWebViewController.m
//  Vote
//
//  Created by 丁 一 on 14-11-6.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteWebViewController.h"

@interface VoteWebViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIView *loadingView;

@end

@implementation VoteWebViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.navTitle;
    CGRect rect = [UIScreen mainScreen].bounds;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, rect.size.width, rect.size.height - NAVIGATION_BAR_HEIGHT)];
    self.webView.userInteractionEnabled = YES;
    self.webView.delegate = self;
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, rect.size.width, rect.size.height - NAVIGATION_BAR_HEIGHT)];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadingView];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingView setHidden:NO];
    [self.loadingView setBackgroundColor:[UIColor blackColor]];
    self.loadingView.alpha = 0.3;
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0f, 32.0f)];
    aiv.center = CGPointMake(FRAME_WIDTH(self.loadingView)*0.5, (FRAME_HEIGHT(self.loadingView) - NAVIGATION_BAR_HEIGHT)*0.5);
    [aiv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.loadingView addSubview:aiv];
    [aiv startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingView setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.loadingView setHidden:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
