//
//  AppDelegate.m
//  AppleScriptPubSubCrash
//
//  Created by Dave Dribin on 1/15/09.
//  Copyright 2009 Bit Maki, Inc.. All rights reserved.
//

#import "AppDelegate.h"
#import <PubSub/PubSub.h>

#define NEW_FEED_EACH_REFRESH 1 // Must be 1 to recreate crash
#define USE_COMPILED_SCRIPT 0   // Must be 0 to recreate crash

@interface AppDelegate ()

@property (nonatomic, getter=isRefreshing) BOOL refreshing;

- (void)createFeed;
- (void)feedRefreshChanged:(NSNotification *)notification;

@end

@implementation AppDelegate

@synthesize refreshing = _refreshing;

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
#if !NEW_FEED_EACH_REFRESH
    [self createFeed];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedRefreshChanged:)
                                                 name:PSFeedRefreshingNotification
                                               object:nil];
    
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_feed release];
    
    [super dealloc];
}

- (void)createFeed;
{
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSString * feedDataPath = [mainBundle pathForResource:@"hotnews" ofType:@"rss"];
    NSData * feedData = [NSData dataWithContentsOfFile:feedDataPath];
    NSURL * url = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    _feed = [[PSFeed alloc] initWithData:feedData URL:url];
}

- (IBAction)refresh:(id)sender;
{
    if (self.refreshing)
        return;
    
    NSLog(@"Start refreshing");
    self.refreshing = YES;

#if NEW_FEED_EACH_REFRESH
    [self createFeed];
#endif
    
    [_feed refresh:nil];
}

- (void)feedRefreshChanged:(NSNotification *)notification;
{
    self.refreshing = [_feed isRefreshing];
    NSLog(@"Refreshing changed: %@", self.isRefreshing? @"Yes" : @"No");

#if NEW_FEED_EACH_REFRESH
    if (!self.refreshing)
    {
        [_feed release];
        _feed = nil;
    }
#endif
}

- (IBAction)runAppleScript:(id)sender;
{
    NSString * scriptName = @"FooScript";
#if USE_COMPILED_SCRIPT
    NSString * scriptPath = [[NSBundle mainBundle] pathForResource:scriptName ofType:@"scpt" inDirectory:@"Scripts"];
#else
    NSString * scriptPath = [[NSBundle mainBundle] pathForResource:scriptName ofType:@"applescript"];
#endif
    NSURL *scriptUrl = [NSURL fileURLWithPath:scriptPath];
    
    NSDictionary * errorDict = nil;
    NSAppleScript * script = [[NSAppleScript alloc] initWithContentsOfURL:scriptUrl error:&errorDict];
    if (script == nil)
    {
        NSLog(@"Loading apple script error: %@", errorDict);
        return;
    }
    
    errorDict = nil;
    [script executeAndReturnError:&errorDict];
}

@end
