//
//  SinaWeiboController.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011 DDMap. All rights reserved.
//

#import "SinaWeiboController.h"
#import "ColorLog.h"

@implementation SinaWeiboController

@synthesize delegate = _delegate;

- (void)dealloc {
	self.delegate = nil;
	[consumer release];
	[token release];
	[super dealloc];
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
			didFailSelector:@selector(requestTokenTicket:failedWithError:)
     ];
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data {
    NIF_INFO();
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(@"responseString : %@", responseString);
    [token release];
    token = [[OAToken alloc] initWithHTTPResponseBody:responseString];
    
    [responseString release];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
				selector:@selector(recievedVerifier:)
				name:kSinaOAuthCallBackNotification object:NULL];
    NSString *urlString = [SINA_AUTHORIZE_URL stringByAppendingFormat:@"?%@&oauth_callback=ddsharebox://%@",responseString,kSinaOAuthCallBackNotification];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
	NSLog(@"%@",error);
    
}

// Step 2
- (void)recievedVerifier:(NSNotification *)notification {
    
    // SINA 
    if ([[notification name] isEqualToString:kSinaOAuthCallBackNotification]) {
        NSString *responseString = [[notification userInfo] objectForKey:kSinaOAuthCallBackNotification];
        //token = [[OAToken alloc] initWithHTTPResponseBody:responseString];
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
    [responseString release];
	
	[[NSUserDefaults standardUserDefaults] setObject:responseString forKey:SINA_USERDEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)accessTokenTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
    NIF_INFO(LCL_YELLOW @"%s,%@",_cmd,error);
	
	
}

@end
