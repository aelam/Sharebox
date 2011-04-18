//
//  OAuthURL.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

typedef enum  {
    kServiceProviderSinaWeibo		= 0,
    kServiceProviderQZone,
	kServiceProviderTotalCount,
}kServiceProvider;



#define CALL_BACK_URL           @"ddsharebox://"

//
// ---------------
// Notification Name
#define kSinaOAuthCallBackNotification  @"kSinaOAuthCallBackNotification"
#define kQQOAuthCallBackNotification    @"kQQWeiboOAuthCallBackNotification"


// SINA围脖
#define SINA_REQUEST_TOKEN_URL	@"http://api.t.sina.com.cn/oauth/request_token"
#define SINA_AUTHORIZE_URL      @"http://api.t.sina.com.cn/oauth/authorize"
#define SINA_ACCESS_TOKEN_URL	@"http://api.t.sina.com.cn/oauth/access_token"
#define SINA_APP_KEY            @"1835539611"
#define SINA_APP_SECRET         @"be64a1a9064c431c3dfd51b0728caf90"


#define SINA_REQUEST_ERROR_CODE 1000
#define SINA_ACCESS_ERROR_CODE	1001

#define SINA_USERDEFAULT_KEY	@"SINA_USERDEFAULT_KEY"

#define SINA_USER_INFO_URL		@"http://api.t.sina.com.cn/users/show.json"
#define SINA_UPDATE_URL			@"http://api.t.sina.com.cn/statuses/update.json"
#define SINA_UPLOAD_IMAGE_URL	@"http://api.t.sina.com.cn/statuses/upload.json"

// QQ围脖
