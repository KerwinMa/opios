/*
 
 Copyright (c) 2012, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */

#import "OpenPeer.h"
#import "Utility.h"
#import "AppConsts.h"
#import "AppCredentials.h"
#import "Logger.h"
//SDK
#import "OpenpeerSDK/HOPStack.h"
#import "OpenpeerSDK/HOPLogger.h"
#import "OpenpeerSDK/HOPMediaEngine.h"
#import "OpenpeerSDK/HOPCache.h"
//Managers
#import "LoginManager.h"
//Delegates
#import "StackDelegate.h"
#import "MediaEngineDelegate.h"
#import "ConversationThreadDelegate.h"
#import "CallDelegate.h"
#import "AccountDelegate.h"
#import "IdentityDelegate.h"
#import "IdentityLookupDelegate.h"
#import "CacheDelegate.h"
//View controllers
#import "MainViewController.h"



//Private methods
@interface OpenPeer ()

- (void) createDelegates;
//- (void) setLogLevels;
@end


@implementation OpenPeer

/**
 Retrieves singleton object of the Open Peer.
 @return Singleton object of the Open Peer.
 */
+ (id) sharedOpenPeer
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString*) authorizedApplicationId
{
    if (!_authorizedApplicationId)
    {
        NSDate* expiry = [[NSDate date] dateByAddingTimeInterval:(30 * 24 * 60 * 60)];
        
        _authorizedApplicationId = [HOPStack createAuthorizedApplicationID:applicationId applicationIDSharedSecret:applicationIdSharedSecret expires:expiry];
    }
    return _authorizedApplicationId;
}

- (NSString*) deviceId
{
    if (!_deviceId)
    {
        _deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:keyOpenPeerUser];
        if ([_deviceId length] == 0)
        {
            _deviceId = [Utility getGUIDstring];
            [[NSUserDefaults standardUserDefaults] setObject:_deviceId forKey:keyOpenPeerUser];
        }
    }
    return _deviceId;
}
/**
 Initializes the open peer stack. After initialization succeeds, login screen is displayed, or user relogin started.
 @param inMainViewController MainViewController Input main view controller.
 */
- (void) setup
{
    //Init cache singleton
    [[HOPCache sharedCache] setDelegate:self.cacheDelegate];
    
    //Set log levels and start logging
    [Logger startAllSelectedLoggers];

    //Created all delegates required for openpeer stack initialization.
    [self createDelegates];

    //Init openpeer stack and set created delegates
    [[HOPStack sharedStack] setupWithStackDelegate:self.stackDelegate mediaEngineDelegate:self.mediaEngineDelegate appID: self.authorizedApplicationId appName:applicationName appImageURL:applicationImageURL appURL:applicationURL userAgent:[Utility getUserAgentName] deviceID:self.deviceId deviceOs:[Utility getDeviceOs] system:[Utility getPlatform]];

    //Start with login procedure and display login view
    [[LoginManager sharedLoginManager] login];
    
    [[HOPMediaEngine sharedInstance] setEcEnabled:[[Settings sharedSettings] isMediaAECOn]];
    [[HOPMediaEngine sharedInstance] setAgcEnabled:[[Settings sharedSettings] isMediaAGCOn]];
    [[HOPMediaEngine sharedInstance] setNsEnabled:[[Settings sharedSettings] isMediaNSOn]];
}

- (void) shutdown
{
    [[HOPStack sharedStack] shutdown];
    
    self.stackDelegate = nil;
    self.mediaEngineDelegate = nil;
    self.conversationThreadDelegate = nil;
    self.callDelegate = nil;
    self.accountDelegate = nil;
    self.identityDelegate = nil;
    self.identityLookupDelegate = nil;
    self.cacheDelegate = nil;
}
/**
 Method used for all delegates creation. Delegates will catch events from the Open Peer SDK and handle them properly.
 */
- (void) createDelegates
{
    self.stackDelegate = [[StackDelegate alloc] init];
    self.mediaEngineDelegate = [[MediaEngineDelegate alloc] init];
    self.conversationThreadDelegate = [[ConversationThreadDelegate alloc] init];
    self.callDelegate = [[CallDelegate alloc] init];
    self.accountDelegate = [[AccountDelegate alloc] init];
    self.identityDelegate = [[IdentityDelegate alloc] init];
    self.identityDelegate.loginDelegate = self.mainViewController;
    self.identityLookupDelegate = [[IdentityLookupDelegate alloc] init];
    self.cacheDelegate = [[CacheDelegate alloc] init];
}
@end
