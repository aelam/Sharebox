//
//  RootViewController.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "OAuthConsumer.h"
#import "OAuthConstants.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    OAConsumer *consumer;
    OAHMAC_SHA1SignatureProvider *provider;
    OAToken *token;
}

@end
