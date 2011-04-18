//
//  SinaWeiboController.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011 DDMap. All rights reserved.
//

#import "SinaWeiboController.h"
#import "ColorLog.h"

BOOL hasVerified() {
	NSString *verifer = [[NSUserDefaults standardUserDefaults] valueForKey:SINA_USERDEFAULT_KEY];
	if (verifer && [verifer length]) {
		return YES;
	}
	return NO;
}

@implementation SinaWeiboController

@synthesize delegate = _delegate;

- (void)dealloc {
	self.delegate = nil;
	[consumer release];
	[signatureProvider release];
	[token release];
	[super dealloc];
}

- (id)initWithDelegate:(id<WeiboProtocol>)aDelegate {
	if (self = [super init]) {
		_delegate = aDelegate;
		isVerified = hasVerified();
		
		consumer = [[OAConsumer alloc] initWithKey:SINA_APP_KEY secret:SINA_APP_SECRET];
		signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
	}
	return self;
}

// Step 1
- (void)startRequestToken  {
    
    SinaOAURLRequest *request = [[[SinaOAURLRequest alloc] initWithURL:[NSURL URLWithString:SINA_REQUEST_TOKEN_URL]
										consumer:consumer
										token:NULL
										realm:NULL
										signatureProvider:signatureProvider
                                  ]autorelease] ;
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    
    [fetcher fetchDataWithRequest:request 
			delegate:self
			didFinishSelector:@selector(requestTokenTicket:finishedWithData:)
			didFailSelector:@selector(requestTicket:failedWithError:)
     ];
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data {
    NIF_INFO();
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(@"responseString : %@", responseString);
	
	[token release]; token = nil;
    token = [[OAToken alloc] initWithHTTPResponseBody:responseString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
				selector:@selector(recievedVerifier:)
				name:kSinaOAuthCallBackNotification object:NULL];
    NSString *urlString = [SINA_AUTHORIZE_URL stringByAppendingFormat:@"?%@&oauth_callback=ddsharebox://%@",responseString,kSinaOAuthCallBackNotification];

	[responseString release];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

- (void)requestTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
	NSLog(@"%@",error);
    
}

// Step 2
- (void)recievedVerifier:(NSNotification *)notification {
    
    // SINA 
    if ([[notification name] isEqualToString:kSinaOAuthCallBackNotification]) {
        NSString *responseString = [[notification userInfo] objectForKey:kSinaOAuthCallBackNotification];

        NSArray *verifierArr = [responseString componentsSeparatedByString:@"oauth_verifier="];
        NIF_INFO(LCL_RED @"verifierArr - %@", verifierArr);
        if (!verifierArr || ![verifierArr count] == 2) {
            return;
        }
        NSString *verifier = [verifierArr objectAtIndex:1];
        
        SinaOAURLRequest *request = [[[SinaOAURLRequest alloc]
                                      initWithURL:[NSURL URLWithString:SINA_ACCESS_TOKEN_URL]
                                      consumer:consumer
                                      token:token
                                      realm:NULL
                                      verifier:verifier
                                      signatureProvider:signatureProvider
                                      ]autorelease] ;
        
        [request setHTTPMethod:@"POST"];
        OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
        
        [fetcher fetchDataWithRequest:request 
				delegate:self
				didFinishSelector:@selector(accessTokenTicket:finishedWithData:)
				didFailSelector:@selector(accessTokenTicket:failedWithError:)
         ];
        
        return;
    }
    
    
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data {
    NIF_INFO(LCL_YELLOW @"%s",_cmd);
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(LCL_RED @"responseString : %@", responseString);
	
	[[NSUserDefaults standardUserDefaults] setObject:responseString forKey:SINA_USERDEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

	if ([_delegate respondsToSelector:@selector(controller:serviceProvider:requestSuccess:)]) {
		[_delegate controller:self serviceProvider:kServiceProviderSinaWeibo requestSuccess:responseString];
	}
	
	[responseString release];

	// TRest
	[self updateStatus:@""];
}


//- (void)accessTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
//    NIF_INFO(LCL_YELLOW @"%s,%@",_cmd,error);
//	if ([_delegate respondsToSelector:@selector(controller:serviceProvider:requestFailed:)]) {
//		[_delegate controller:self serviceProvider:kServiceProviderSinaWeibo requestFailed:error];
//	}
//		
//}

- (void)updateStatus:(NSString *)status {
	
	NSString *responseBody = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USERDEFAULT_KEY];
	NSArray *temp = [responseBody componentsSeparatedByString:@"user_id="];
	if (!temp || [temp count] < 2) {
		return;
	}
	NSString *userId = [temp objectAtIndex:1];
	NIF_INFO(@"userId : %@",userId);
	
	[token release]; token = nil;
	token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    NIF_INFO(LCL_RED @"responseString : %@", responseBody);
	NIF_INFO(LCL_RED @"token : key %@ secret %@", [token key],[token secret]);
	
	
	NSString *postBody = @"test";
	
	SinaOAURLRequest *request = [[[SinaOAURLRequest alloc]
								  initWithURL:[NSURL URLWithString:SINA_UPLOAD_IMAGE_URL]
								  consumer:consumer
								  token:token
								  realm:NULL
								  signatureProvider:signatureProvider
								  ]autorelease];
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"TestTestTestTestTest",@"status",nil];
	request.extraOAuthParameters = dic;

	
	[request setHTTPMethod:@"POST"];
	
	OAAsynchronousDataFetcher *fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
				delegate:self didFinishSelector:@selector(postStatusTicket:finishedWithData:) 
				didFailSelector:@selector(requestTicket:failedWithError:)];
	[fetcher start];
	
}

- (void)postStatusTicket:(OAServiceTicket *)ticket finishedWithData:(NSData *)data {
    NIF_INFO(LCL_YELLOW @"%s",_cmd);
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(LCL_RED @"responseString : %@", responseString);
	
}

//- (void)postStatusTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
//	NIF_INFO(@"%@",error);
//}


@end
