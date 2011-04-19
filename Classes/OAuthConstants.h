//
//  OAuthURL.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

typedef enum  {
    kServiceProviderSinaWeibo		= 0,
    kServiceProviderQQWeibo,
    kServiceProviderQZone,
	kServiceProviderTotalCount,
}kServiceProvider;



#define CALL_BACK_URL           @"ddsharebox://"

//
// ---------------
// Notification Name
#define kSinaOAuthCallBackNotification			@"kSinaOAuthCallBackNotification"
#define kQQWeiboOAuthCallBackNotification		@"kQQWeiboOAuthCallBackNotification"


// SINA围脖
#define SINA_REQUEST_TOKEN_URL	@"http://api.t.sina.com.cn/oauth/request_token"
#define SINA_AUTHORIZE_URL      @"http://api.t.sina.com.cn/oauth/authorize"
#define SINA_ACCESS_TOKEN_URL	@"http://api.t.sina.com.cn/oauth/access_token"
#define SINA_APP_KEY            @"1835539611"
#define SINA_APP_SECRET         @"be64a1a9064c431c3dfd51b0728caf90"


#define SINA_REQUEST_ERROR_CODE 1000
#define SINA_ACCESS_ERROR_CODE	1001

#define SINA_USERDEFAULT_KEY	@"SINA_USERDEFAULT_KEY"

#define SINA_USER_INFO_URL		@"http://api.t.qq.com.cn/users/show.json"
#define SINA_UPDATE_URL			@"http://api.t.qq.com.cn/statuses/update.json"
#define SINA_UPLOAD_IMAGE_URL	@"http://api.t.qq.com.cn/statuses/upload.json"

// QQ围脖
#define QQ_REQUEST_TOKEN_URL	@"https://open.t.qq.com/cgi-bin/request_token"
#define QQ_AUTHORIZE_URL		@"https://open.t.qq.com/cgi-bin/authorize"
#define QQ_ACCESS_TOKEN_URL		@"https://open.t.qq.com/cgi-bin/access_token"
#define QQ_APP_KEY				@"14a6b38d5ffe47c7a9acd86902660cdd"
#define QQ_APP_SECRET			@"3016f15bfcf6990f4fb71b4a368d950f"


#define QQ_REQUEST_ERROR_CODE	2000
#define QQ_ACCESS_ERROR_CODE	2001

#define QQ_USERDEFAULT_KEY		@"QQ_USERDEFAULT_KEY"

#define QQ_UPDATE_URL			@"http://open.t.qq.com/api/t/add"
#define QQ_UPLOAD_IMAGE_URL		@"http://open.t.qq.com/api/t/add_pic"

//test
//#define CALL_BACK_URL			@"WaQQ://www.baidu.com"

/**
 t/add 发表一条微博
 
 URL：http://open.t.qq.com/api/t/add
 格式：xml,json
 HTTP请求方式：POST
 是否需要鉴权：true
 请求数限制：true
 关于请求数限制，参见API调用权限说明
 
 请求参数：oauth标准参数，并带上以下参数
 Format: 返回数据的格式 是（json或xml）
 content: 微博内容 必填项
 Clientip: 用户IP 必填项，请带上用户浏览器带过来的IP地址，否则会被消息过滤策略拒绝掉
 Jing: 经度（可以填空）
 Wei: 纬度（可以填空）
 
 使用示例如下：
 http://open.t.qq.com/api/t/add
 Post包体格式：
 format=json&content=xxxx&clientip=127.0.0.1&jing=110.5&wei=23.4
 
 返回结果：
 {
 ret:0,
 Msg:"ok",
 Errcode:0,
 Data:{
 id:12345678,
 Timestamp:12863444444
 ｝
 }
 Errcode :发表失败错误码参看文档最后说明
 
 ===============================================================================
 
 t/add_pic 发表一条带图片的微博
 
 URL：http://open.t.qq.com/api/t/add_pic
 格式：xml,json
 HTTP请求方式：POST
 是否需要鉴权：true
 请求数限制：true
 关于请求数限制，参见API调用权限说明
 
 请求参数：oauth标准参数，并带上以下参数
 Format: 返回数据的格式 是（json或xml）
 content: 微博内容 必填项
 Clientip: 用户IP 必填项，请带上用户浏览器带过来的IP地址，否则会被消息过滤策略拒绝掉
 Jing: 经度（可以填空）
 Wei: 纬度（可以填空）
 Pic:文件域表单名 本字段不要签名的参数中，不然请求时会出现签名错误
 
 使用示例如下：
 http://open.t.qq.com/api/t/add_pic
 Post包体格式：
 提交数据 采用enctype="multipart/form-data" 
 
 返回结果：
 {
 ret:0,
 Msg:"ok",
 Errcode:13,
 Data:{
 id:12345678,
 Timestamp:12863444444
 }
 }
 
 
 errcode=0 表示成功 errcode=4 表示有过多脏话 errcode=5 禁止访问，如城市，uin黑名单限制等 errcode=6 删除时：该记录不存在。发表时：父节点已不存在 errcode=8 内容超过最大长度：420字节 （以进行短url处理后的长度计） errcode=9 包含垃圾信息：广告，恶意链接、黑名单号码等 errcode=10 发表太快，被频率限制 errcode=11 源消息已删除，如转播或回复时 errcode=12 源消息审核中 errcode=13 重复发表
 
 */

