//
//  RootViewController.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboProtocol.h"

@class SinaWeiboController;
@class WebBaseViewController;
@class QQWeiboController;

@interface RootViewController : UITableViewController <WeiboProtocol> {
    
	SinaWeiboController *sinaWeiboController;
	QQWeiboController *qqWeiboController;
	WebBaseViewController *qzoneShareViewController;
}

@end
