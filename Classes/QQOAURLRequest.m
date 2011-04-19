//
//  QQOAURLRequest.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QQOAURLRequest.h"
#import "NSString+Additions.h"
#import "ColorLog.h"

@interface QQOAURLRequest (Private)
- (NSString *)_signatureBaseString;
@end


@implementation QQOAURLRequest

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
		 callback:(NSString *)aCallback
         verifier:(NSString *)aVerifier
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider 
{
    if (self = [super initWithURL:aUrl
					  cachePolicy:NSURLRequestReloadIgnoringCacheData
				  timeoutInterval:10.0])
	{    
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else 
			realm = [aRealm retain];
		
		if (callback == nil) {
			callback = [aCallback copy];
		}
		
		if (verifier == nil) {
			verifier = [aVerifier copy];
		}
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = [aProvider retain];
		
		timestamp = [[NSString timestamp] copy];
		nonce = [[NSString qq_nonce] copy];
	}
    return self;
}


- (void)dealloc
{
	[callback release];
    [verifier release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue
{
	assert(parameterName && parameterValue);
	
	if (extraOAuthParameters == nil) {
		extraOAuthParameters = [NSMutableDictionary new];
	}
	
	[extraOAuthParameters setObject:parameterValue forKey:parameterName];
}

- (void)prepare 
{
    // sign
	// Secrets must be urlencoded before concatenated with '&'
	// TODO: if later RSA-SHA1 support is added then a little code redesign is needed
    signature = [signatureProvider signClearText:[self _signatureBaseString]
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
    
    // set OAuth headers
    NSString *oauthToken;
    if ([token.key isEqualToString:@""])
        oauthToken = @""; // not used on Request Token transactions
    else
        oauthToken = [NSString stringWithFormat:@"&oauth_token=%@", [token.key URLEncodedString]];
	
	NSMutableString *extraParameters = [NSMutableString string];
	
	if (verifier && verifier.length) {
		[extraParameters appendFormat:@"&oauth_verifier=%@",[verifier URLEncodedString]];
	}
	
	NSString *callBackTotal = @"";
	if (callback && callback.length) {
		callBackTotal = [NSString stringWithFormat:@"&oauth_callback=%@",[callback URLEncodedString]];
	}
	
	// Adding the optional parameters in sorted order isn't required by the OAuth spec, but it makes it possible to hard-code expected values in the unit tests.
	for(NSString *parameterName in [[extraOAuthParameters allKeys] sortedArrayUsingSelector:@selector(compare:)])
	{
		[extraParameters appendFormat:@"&%@=%@",
		 [parameterName URLEncodedString],
		 [[extraOAuthParameters objectForKey:parameterName] URLEncodedString]];
	}	
    
    NSString *oauthHeader = [NSString stringWithFormat:@"oauth_consumer_key=%@%@&oauth_signature_method=%@&oauth_signature=%@&oauth_timestamp=%@&oauth_nonce=%@&oauth_version=1.0%@%@",
                             [consumer.key URLEncodedString],
                             oauthToken,
                             [[signatureProvider name] URLEncodedString],
                             [signature URLEncodedString],
                             timestamp,
                             nonce,
							 callBackTotal,//[self.callback URLEncodedString],
							 extraParameters];
	
	NSString *newURL = nil;
	if ([[self.URL query] length]) {
		newURL = [NSString stringWithFormat:@"%@&%@",[self.URL description],oauthHeader];
	}
	else {
		newURL = [NSString stringWithFormat:@"%@?%@",[self.URL description],oauthHeader];		
	}
	
	NIF_INFO(@"%@",newURL);
	
	self.URL = [NSURL URLWithString:newURL];
}

- (NSString *)_signatureBaseString 
{
    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:(6 + [[self parameters] count])]; // 6 being the number of OAuth params in the Signature Base String
    //NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:6]; // 6 being the number of OAuth params in the Signature Base String
    
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" value:[signatureProvider name]] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
	if (callback && callback.length) {
		[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_callback" value:callback] URLEncodedNameValuePair]];
	}
	if (verifier && verifier.length) {
		[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_verifier" value:verifier] URLEncodedNameValuePair]];
	}
	
    if (![token.key isEqualToString:@""]) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" value:token.key] URLEncodedNameValuePair]];
    }
	
    for (OARequestParameter *param in [self parameters]) {
        [parameterPairs addObject:[param URLEncodedNameValuePair]];
    }
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 [self HTTPMethod],
					 [[[self URL] URLStringWithoutQuery] URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
	
	return ret;
}

@end
