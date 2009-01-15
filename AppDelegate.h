//
//  AppDelegate.h
//  AppleScriptPubSubCrash
//
//  Created by Dave Dribin on 1/15/09.
//  Copyright 2009 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PSFeed;

@interface AppDelegate : NSObject
{
    PSFeed * _feed;
    BOOL _refreshing;
}

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (IBAction)refreshFeed:(id)sender;

- (IBAction)runAppleScript:(id)sender;

- (IBAction)cleanupXMLParser:(id)sender;

@end
