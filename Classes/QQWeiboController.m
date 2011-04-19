//
//  QQWeiboController.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QQWeiboController.h"
#import "ColorLog.h"
#import "QQOAURLRequest.h"

//BOOL hasVerified() {
//	NSString *verifer = [[NSUserDefaults standardUserDefaults] valueForKey:QQ_USERDEFAULT_KEY];
//	if (verifer && [verifer length]) {
//		return YES;
//	}
//	return NO;
//}
BOOL hasQQWeiboVerified() {
	NSString *verifer = [[NSUserDefaults standardUserDefaults] valueForKey:QQ_USERDEFAULT_KEY];
	if (verifer && [verifer length]) {
		return YES;
	}
	return NO;
}



@implementation QQWeiboController

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
		isVerified = hasQQWeiboVerified();
		
		consumer = [[OAConsumer alloc] initWithKey:QQ_APP_KEY secret:QQ_APP_SECRET];
		signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
	}
	return self;
}

// Step 1
- (void)startRequestToken  {
    
	NSString *callback = [NSString stringWithFormat:@"ddsharebox://%@",kQQWeiboOAuthCallBackNotification];
    QQOAURLRequest *request = [[[QQOAURLRequest alloc] initWithURL:[NSURL URLWithString:QQ_REQUEST_TOKEN_URL]
									consumer:consumer
									token:NULL
									realm:NULL
									callback:callback
									verifier:NULL
									signatureProvider:signatureProvider
                                  ]autorelease] ;
	
//	[request setOAuthParameterName:@"oauth_callback"
//						 withValue: [NSString stringWithFormat:@"ddsharebox://%@",kQQWeiboOAuthCallBackNotification]];
	
    [request setHTTPMethod:@"GET"];
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
    NIF_INFO(@"responseString : key %@ ,secret : %@", token.key,token.secret);
    
	
    [[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(recievedVerifier:)
			name:kQQWeiboOAuthCallBackNotification object:NULL];
    NSString *urlString = [QQ_AUTHORIZE_URL stringByAppendingFormat:@"?%@&oauth_callback=ddsharebox://%@",responseString,kQQWeiboOAuthCallBackNotification];
	
	[responseString release];
	
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

- (void)requestTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error {
	NSLog(@"%@",error);
    
}

// Step 2
- (void)recievedVerifier:(NSNotification *)notification {
    
    // QQ 
    if ([[notification name] isEqualToString:kQQWeiboOAuthCallBackNotification]) {
        NSString *responseString = [[notification userInfo] objectForKey:kQQWeiboOAuthCallBackNotification];
		
        NSArray *verifierArr = [responseString componentsSeparatedByString:@"oauth_verifier="];
        NIF_INFO(LCL_RED @"verifierArr - %@", verifierArr);
        if (!verifierArr || ![verifierArr count] == 2) {
            return;
        }
        NSString *verifier = [verifierArr objectAtIndex:1];
        
        QQOAURLRequest *request = [[[QQOAURLRequest alloc]
										initWithURL:[NSURL URLWithString:QQ_ACCESS_TOKEN_URL]
										consumer:consumer
										token:token
										realm:NULL
										callback:NULL
										verifier:verifier
										signatureProvider:signatureProvider
                                      ]autorelease];
        
        [request setHTTPMethod:@"POST"];
        OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
        
        [fetcher fetchDataWithRequest:request 
							 delegate:self
					didFinishSelector:@selector(accessTokenTicket:finishedWithData:)
					  didFailSelector:@selector(requestTicket:failedWithError:)
         ];
        
        return;
    }
    
    
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data {
    NIF_INFO(LCL_YELLOW @"%s",_cmd);
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NIF_INFO(LCL_RED @"responseString : %@", responseString);
	
	[[NSUserDefaults standardUserDefaults] setObject:responseString forKey:QQ_USERDEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([_delegate respondsToSelector:@selector(controller:serviceProvider:requestSuccess:)]) {
		[_delegate controller:self serviceProvider:kServiceProviderQQWeibo requestSuccess:responseString];
	}
	
	[responseString release];
	
	// TRest
	[self updateStatus:@""];
}

- (void)updateStatus:(NSString *)status {
	
	NSString *responseBody = [[NSUserDefaults standardUserDefaults] objectForKey:QQ_USERDEFAULT_KEY];
	NSArray *temp = [responseBody componentsSeparatedByString:@"&name="];
	if (!temp || [temp count] < 2) {
		return;
	}
	NSString *userId = [temp objectAtIndex:1];
	NIF_INFO(@"userId : %@",userId);
	
	[token release]; token = nil;
	token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    NIF_INFO(LCL_RED @"responseString : %@", responseBody);
	NIF_INFO(LCL_RED @"token : key %@ secret %@", [token key],[token secret]);
	
	NSString *body = @"format=json&content=xxxx&clientip=127.0.0.1&jing=110.5&wei=23.4";
	

	QQOAURLRequest *request = [[[QQOAURLRequest alloc]
									initWithURL:[NSURL URLWithString:QQ_UPDATE_URL]
									consumer:consumer
									token:token
									realm:NULL
									callback:NULL
									verifier:NULL
									signatureProvider:signatureProvider
								  ]autorelease];
	[request setHTTPMethod:@"POST"];
	NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:bodyData];
	
//	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"TestTestTestTestTest",@"status",nil];
//	request.extraOAuthParameters = dic;
	
	
//	[request setHTTPMethod:@"POST"];
	
	OAAsynchronousDataFetcher *fetcher = [[OAAsynchronousDataFetcher alloc] initWithRequest:request 
					delegate:self didFinishSelector:@selector(postStatusTicket:finishedWithData:) 
					didFailSelector:@selector(requestTicket:failedWithError:)];
	[fetcher start];
	
}

- (void)postStatus:(NSString *)status image:(UIImage *)image {
	NSData *data = UIImageJPEGRepresentation(image, 1);
	NSString *path = [[NSBundle mainBundle] pathForResource:@"post" ofType:@"png"];
	
	
	CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
	
	NSString *responseBody = [[NSUserDefaults standardUserDefaults] objectForKey:QQ_USERDEFAULT_KEY];

	[token release]; token = nil;
	token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    NIF_INFO(LCL_RED @"responseString : %@", responseBody);
	NIF_INFO(LCL_RED @"token : key %@ secret %@", [token key],[token secret]);
	
	NSString *body = @"format=json&content=xxxx&clientip=127.0.0.1&jing=110.5&wei=23.4&pic=test.png";
	
	
	QQOAURLRequest *request = [[[QQOAURLRequest alloc]
								initWithURL:[NSURL URLWithString:QQ_UPLOAD_IMAGE_URL]
								consumer:consumer
								token:token
								realm:NULL
								callback:NULL
								verifier:NULL
								signatureProvider:signatureProvider
								]autorelease];
	[request setHTTPMethod:@"POST"];
//	NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
//	[request setHTTPBody:bodyData];
	
//	NSDictionary *files = [NSDictionary dictionaryWithObject:path forKey:@"pic"];
	
	NSData *boundaryBytes = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *bodyData = [NSMutableData data];
	NSString *formDataTemplate = @"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@";
	
	NSDictionary *listParams = [NSURL parseURLQueryString:body];
	for (NSString *key in listParams) {
		
		NSString *value = [listParams valueForKey:key];
		NSString *formItem = [NSString stringWithFormat:formDataTemplate, boundary, key, value];
		[bodyData appendData:[formItem dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[bodyData appendData:boundaryBytes];
	
	NSString *headerTemplate = @"Content-Disposition: form-data; name=\"OK\"; filename=\"OK\"\r\nContent-Type: \"application/octet-stream\"\r\n\r\n";
	NIF_INFO(@"%@",headerTemplate);
	//	for (NSString *key in files) {
		
		//NSString *filePath = [files objectForKey:key];
		//NSData *fileData = [NSData dataWithContentsOfFile:filePath];
		NSData *fileData = UIImageJPEGRepresentation(image, 1);

		//NSString *header = [NSString stringWithFormat:headerTemplate, key, [[filePath componentsSeparatedByString:@"/"] lastObject]];
		//NSString *header = [headerTemplate stringByAppendingFormat:@"Test"];	
		[bodyData appendData:[headerTemplate dataUsingEncoding:NSUTF8StringEncoding]];
		[bodyData appendData:fileData];
		[bodyData appendData:boundaryBytes];
//	}
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
//	[request setHTTPBody:bodyData];
	
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

@end
