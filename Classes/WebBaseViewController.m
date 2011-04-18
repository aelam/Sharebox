    //
//  WebBaseViewController.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebBaseViewController.h"


@implementation WebBaseViewController

@synthesize webview;

- (id)init {
	if (self = [super init]) {
		webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		webview.scalesPageToFit = YES;
		self.view = webview;
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//	webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//	self.view = webview;
//	//[webview release];
//}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad {
 //   [super viewDidLoad];
//	webview = [[UIWebView alloc] initWithFrame:self.view.frame];
//	[self.view addSubview:webview];
//}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[webview release];
    [super dealloc];
}


@end
