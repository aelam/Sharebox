//
//  RootViewController.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

#import "RootViewController.h"
#import "ColorLog.h"
#import "SinaWeiboController.h"
#import "WebBaseViewController.h"

@implementation RootViewController



#pragma mark -
#pragma mark View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)dealloc {
	[sinaWeiboController release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"分享";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return kServiceProviderTotalCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.row == kServiceProviderSinaWeibo) {
		cell.textLabel.text = @"新浪微博";
	} else if (indexPath.row == kServiceProviderQZone) {
		cell.textLabel.text = @"腾讯微博";
	}
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row == kServiceProviderSinaWeibo) {
		if (sinaWeiboController == nil) {
			sinaWeiboController = [[SinaWeiboController alloc] initWithDelegate:self];
		}
		//[sinaWeiboController startRequestToken];
		[sinaWeiboController updateStatus:@"OKOK"];
	} else if (indexPath.row == kServiceProviderQZone) {
		if (qzoneShareViewController == nil) {
			qzoneShareViewController = [[WebBaseViewController alloc] init];
		}
		NSURL *url = [NSURL URLWithString:@"http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=http%3A%2F%2Fwww.discuz.net%2F"];
					  
		NIF_INFO(LCL_BLUE @"%@",url);
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[qzoneShareViewController.webview loadRequest:request];
		[self.navigationController pushViewController:qzoneShareViewController animated:YES];
	}
	
}

 
- (void)controller:(id)controller serviceProvider:(NSInteger)provider requestSuccess:(NSString *)tip {
	// tableView Reload 
	NIF_INFO(LCL_BLUE @"%@",tip);
}

- (void)controller:(id)controller serviceProvider:(NSInteger)provider requestFailed:(NSError *)error {
	NIF_INFO(LCL_BLUE @"%@",error);

}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

