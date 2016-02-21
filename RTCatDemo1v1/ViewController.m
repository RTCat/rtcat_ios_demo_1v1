//
//  ViewController.m
//  RTCatDemo1v1
//
//  Created by chencong on 2/19/16.
//  Copyright © 2016 shishimao. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>


#import <RTCatSDK/RTCat.h>
#import <RTCatSDK/RTStream.h>
#import <RTCatSDK/RTSession.h>
#import <RTCatSDK/LTRTCEAGLVideoView.h>


@interface ViewController ()
{
    //RTSender *_localSender;
    RTReceiver *_localReceiver;
    
    NSMutableDictionary *_receivers;
    NSMutableDictionary *_senders;
    
    RTStream *_localStream;
    RTSession *_sessionRTC;
}

@property (strong, nonatomic) LTRTCEAGLVideoView *remoteView;
@property (strong, nonatomic) LTRTCEAGLVideoView *localView;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@end


@interface ViewController (RTCEAGLVideoView)<RTCEAGLVideoViewDelegate>
- (void)initUIView;
@end

@interface ViewController (StreamObserverDelagate)<RTStreamObserverDelagate,RTStreamObserverDelagate>
@end

@interface ViewController (SessionObserverDelagate)<RTSessionObserver,RTReceiverObserver>
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _receivers = [[NSMutableDictionary alloc] init];
    _senders = [[NSMutableDictionary alloc] init];
    
    [self initUIView];
    
    RTCat *cat = [RTCat shareInstance];
    _localStream = [cat createStreamWithVideo:YES withAudio:YES Fps:20 width:_localView.bounds.size.width height:_localView.bounds.size.height videoIndex:RTCamrareFront withDelagete:self];
    [_localStream play:_localView];
    
    
    
    AppDelegate *thaApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [thaApp getP2PServerToken];
    
    [self doRemoteConn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRemoteConn) name:@"tokenServer" object:nil];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRemoteConn {
    AppDelegate *theApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    printf("--->:%s\n",[theApp.tokenServer UTF8String]);
    
    if (nil == theApp.tokenServer) {
        return;
    }
    if (_sessionRTC) {
        return;
    }
    
    RTCat *cat = [RTCat shareInstance];
    _sessionRTC = [cat createSessionWithToken:theApp.tokenServer];
    [_sessionRTC addObserver:self];
    [_sessionRTC connect];
}

@end



@implementation ViewController (StreamObserverDelagate)
- (void)didChangeState:(LTStreamState)state {
    NSLog(@"%s %ld",__FUNCTION__ ,(long)state);
}

- (void)didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    NSLog(@"%s %@",__FUNCTION__ ,localVideoTrack);
}

- (void)didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    NSLog(@"%s %@",__FUNCTION__ ,remoteVideoTrack);
}

- (void)didError:(NSError *)error{
    NSLog(@"%s %@",__FUNCTION__ ,error);
}

@end


@implementation ViewController (RTCEAGLVideoView)
- (void)disconnect {
    
    if (_localVideoTrack && _localView) {
        [_localVideoTrack removeRenderer:_localView];
    }
    if (_remoteVideoTrack && _remoteView) {
        [_remoteVideoTrack removeRenderer:_remoteView];
    }
    
    _localVideoTrack = nil;
    [_localView renderFrame:nil];
    _remoteVideoTrack = nil;
    [_remoteView renderFrame:nil];
    
    //TODO: 执行断开连接
    if (_sessionRTC) {
        [_sessionRTC disconnect];
        _sessionRTC = nil;
    }
}

- (void)initUIView {
    //RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect rRemote = CGRectMake(10, size.height/2, size.width - 20, size.height/2 - 20);
    _remoteView = [[LTRTCEAGLVideoView alloc] initWithFrame:rRemote];
    [_remoteView setBackgroundColor:[UIColor yellowColor]];
    
    CGRect rLocal = CGRectMake(10, 10 + 20, size.width - 20, size.height/2 - 20  - 20);
    _localView = [[LTRTCEAGLVideoView alloc] initWithFrame:rLocal];
    [_localView setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:_remoteView];
    [self.view addSubview:_localView];
    [_remoteView setDelegate:self];
    [_localView setDelegate:self];
}

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"%s",__FUNCTION__);
}

- (void)didChangeState:(LTStreamState)state {
    NSLog(@"%s",__FUNCTION__);
}

- (void)didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    NSLog(@"%s",__FUNCTION__);
    if (self.localVideoTrack) {
        [self.localVideoTrack removeRenderer:self.localView];
        self.localVideoTrack = nil;
        [self.localView renderFrame:nil];
    }
    self.localVideoTrack = localVideoTrack;
    [self.localVideoTrack addRenderer:self.localView];
}

- (void)didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    NSLog(@"%s",__FUNCTION__);
}

- (void)didError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
}

@end


@implementation ViewController (SessionObserverDelagate)
//RTSessionObserver
- (void)sessionInToken:(NSString *)token {
    NSLog(@"RTSessionObserver inToken %@",token);
    //if (nil == _localSender || NULL == _localSender) {
    //    [_sessionRTC sendToWithSender:_localSender to:token];
    //}
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:@"main" forKey:@"type"];
    [attr setObject:@"think" forKey:@"name"];
    
    RTSessionSendConfig *ssc = [[RTSessionSendConfig alloc] initWithStream:_localStream withData:attr isData:true];
    [_sessionRTC sendP2pTo:ssc to:token];
}

- (void)sessionOutToken:(NSString *)token {
    NSLog(@"RTSessionObserver outToken %@",token);
}

- (void)sessionConnected:(NSArray *)wits {
    //RTSessionLinkConfig *slc = [[RTSessionLinkConfig alloc] initWithStream:_localStream];
    //[_sessionRTC link:slc];
    
    NSString *wit = [wits componentsJoinedByString:@"|"];
    NSLog(@"RTSessionObserver connected %@",wit);
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:@"main" forKey:@"type"];
    [attr setObject:@"think" forKey:@"name"];
    
    RTSessionSendConfig *ssc = [[RTSessionSendConfig alloc] initWithStream:_localStream withData:attr isData:true];
    [_sessionRTC sendWithConfig:ssc];
}

- (void)sessionRemote:(RTReceiver *)receiver {
    NSString *name = [receiver.getAttr objectForKey:@"name"];
    NSString *uID = [receiver getId];
    NSLog(@"RTSessionObserver remote %@ -> %@",uID ,name);
    
    [_receivers setObject:receiver forKey:[receiver getId]];
    [receiver addObserver:self];
    [receiver response];
}

- (void)sessionLocal:(RTSender *)sender {
    NSLog(@"RTSessionObserver local %@",sender);
    [_senders setObject:sender forKey:[sender getId]];
    //_localSender = sender;
    //[_sessionRTC sendWithRTSender:_localSender];
}

- (void)sessionMessageWithToken:(NSString *)token messgae:(NSString *)message {
    NSLog(@"%s",__FUNCTION__);
}

- (void)sessionError:(NSString *)error {
    NSLog(@"%s",__FUNCTION__);
}

//RTReceiverObserver
/**
 * 接收到 数据流
 * @param stream
 */
- (void)receiverStream:(RTStream *)stream {
    NSLog(@"%s %@",__FUNCTION__,[stream getVideoTrack]);
    if (self.remoteVideoTrack) {
        [self.remoteVideoTrack removeRenderer:self.remoteView];
        self.remoteVideoTrack = nil;
        [self.remoteView renderFrame:nil];
    }
    self.remoteVideoTrack = [stream getVideoTrack];
    [self.remoteVideoTrack addRenderer:self.remoteView];
}

/**
 * 接收到 消息流
 * @param message
 */
- (void)receiverMessage:(NSString *)message {
    NSLog(@"%s %@",__FUNCTION__,message);
}

/**
 * 触发关闭事件
 */
- (void)receiverClose {
    NSLog(@"%s",__FUNCTION__);
}

@end