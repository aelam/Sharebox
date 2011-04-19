//
//  QQOAURLRequest.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"

@interface QQOAURLRequest : OAMutableURLRequest {
@protected
	
    NSString *verifier;
	NSString *callback;
}

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
		 callback:(NSString *)aCallback
         verifier:(NSString *)aVerifier
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider;

- (void)prepare;

@end
