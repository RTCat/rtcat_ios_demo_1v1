//
//  AppDelegate.h
//  RTCatDemo1v1
//
//  Created by chencong on 2/19/16.
//  Copyright © 2016 shishimao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *tokenServer;

- (void)getP2PServerToken;

@end

