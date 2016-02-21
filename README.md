## 实时猫 iOS 1v1 Demo

[实时猫](https://shishimao.com) iOS 1v1 Demo

## 使用

1.下载代码
```
	git clone https://github.com/RTCat/rtcat_ios_demo_1v1.git
```

2.下载 `RTCat.framework`

3.把 `RTCat.framework` 移到 `rtcat_ios_demo_1v1` 文件夹下

4.用`Xcode` 打开 `RTCatDemo1v1.xcodeproj`

5.通过`实时猫控制台`获得 `apikey` ,`secret`和`p2p session`,并修改 `AppDelegate.m` 代码:

```
[request addValue:@"apikey" forHTTPHeaderField:@"X-RTCAT-APIKEY"]; // 61行 apikey改为控制台获得的 apikey
[request addValue:@"secret" forHTTPHeaderField:@"X-RTCAT-SECRET"];／／ 62行 secret 改为控制台获得的 secret
....
@"session_id": @"session_id"  //67行 session_id 改为控制台获得的 p2p session
    
```

6.运行项目


## 部分代码说明

通过调用 `实时猫RESTful` 接口获得`token` 


`AppDelegate.m`

```

- (void)getP2PServerToken
{

    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    

    NSURL* URL = [NSURL URLWithString:@"https://api.realtimecat.com/v0.1/tokens"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request addValue:@"apikey" forHTTPHeaderField:@"X-RTCAT-APIKEY"];
    [request addValue:@"secret" forHTTPHeaderField:@"X-RTCAT-SECRET"];
    
    // JSON Body
    NSDictionary* bodyObject = @{
                                 @"type": @"pub",
                                 @"session_id": @"session_id"
                                 };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyObject options:kNilOptions error:NULL];
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {

            NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSData *jsondata = [resStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableLeaves error:nil];
            
            resStr = [resDic objectForKey:@"token"];
            printf("Token: %s\n",resStr.UTF8String);
            _tokenServer = resStr;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenServer" object:nil];
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            _tokenServer = nil;
        }
    }];
    [task resume];
}

```






