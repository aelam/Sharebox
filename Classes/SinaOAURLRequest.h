//
//  SinaOAURLRequest.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011年 DDMap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"

@interface SinaOAURLRequest : OAMutableURLRequest {
@protected

    NSString *verifier;
    
}

// With Verifier 
- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
         verifier:(NSString *)aVerifier
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider;

- (void)prepare;

@end
