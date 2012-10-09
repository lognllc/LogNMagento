//
//  AppDelegate.h
//
//  Created by Rex Sheng on 9/5/12.
//  Copyright (c) 2012 Log(n) LLC. All rights reserved.
//

#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

#else

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSArrayController *logsArrayController;

@end

#endif
