//
//  QQWeiboController.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#import "OAuthConstants.h"
#import "WeiboProtocol.h"

@interface QQWeiboController : NSObject {
	BOOL							isVerified;
	OAToken							*token;
	OAConsumer						*consumer;
	OAHMAC_SHA1SignatureProvider	*signatureProvider;
	
	id <WeiboProtocol>				_delegate;
	
}

@property (assign) id <WeiboProtocol> delegate;

- (id)initWithDelegate:(id<WeiboProtocol>)aDelegate;

- (void)startRequestToken;

- (void)updateStatus:(NSString *)status;
- (void)postStatus:(NSString *)status image:(UIImage *)image;

@end