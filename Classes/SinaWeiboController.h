//
//  SinaWeiboController.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011 DDMap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#import "OAuthConstants.h"
#import "WeiboProtocol.h"

typedef enum  {
    kServiceProviderSina,
    kServiceProviderTencent,
	//    kServiceProviderSina,
}kServiceProvider;


@interface SinaWeiboController : NSObject {
	
	BOOL							isVerified;
	OAToken							*token;
	OAConsumer						*consumer;
	OAHMAC_SHA1SignatureProvider	*signatureProvider;

	id <WeiboProtocol>				_delegate;
	
}

@property (assign) id <WeiboProtocol> delegate;

- (id)initWithDelegate:(id<WeiboProtocol>)aDelegate;

- (void)startRequestToken;



- (void)postStatus:(NSString *)status image:(UIImage *)image;

@end
