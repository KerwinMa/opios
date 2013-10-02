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

#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/Foundation.h>

#import "OpenPeerUser.h"
#import "Utility.h"
//SDK
#import <OpenpeerSDK/HOPAccount.h>
#import <OpenpeerSDK/HOPContact.h>
#import <OpenpeerSDK/HOPHomeUser.h>
#import <OpenpeerSDK/HOPModelManager.h>
#import <OpenpeerSDK/HOPAssociatedIdentity.h>
#import <OpenpeerSDK/HOPRolodexContact.h>
//Utility
#import "XMLWriter.h"
#import "Constants.h"


//Private methods
@interface OpenPeerUser()

- (id) initSingleton;

@end

@implementation OpenPeerUser

/**
 Retrieves singleton object of the Open Peer User.
 @return Singleton object of the Open Peer User.
 */
+ (id) sharedOpenPeerUser
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

/**
 Initialization of Open Peer User singleton object.
 @return Object of the Open Peer User.
 */
- (id) initSingleton
{
    self = [super init];
    
    if (self)
    {
        self.deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:keyOpenPeerUser];
//        if (data)
//        {
//            NSKeyedUnarchiver *aDecoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//            
//            self.deviceId = [aDecoder decodeObjectForKey:archiveDeviceId];
            //self.stableUniqueId = [aDecoder decodeObjectForKey:archiveStableUniqueId];
//            self.identityURI = [aDecoder decodeObjectForKey:archiveIdentityURI];
//            self.peerURI = [aDecoder decodeObjectForKey:archivePeerURI];
//            self.privatePeerFile = [aDecoder decodeObjectForKey:archivePrivatePeerFile];
//            self.privatePeerFileSecret = [aDecoder decodeObjectForKey:archivePrivatePeerFileSecret];
//            self.fullName = [aDecoder decodeObjectForKey:archivePeerFilePassword];
//            self.dictionaryIdentities = [aDecoder decodeObjectForKey:archiveAssociatedIdentities];
//            self.reloginInfo = [aDecoder decodeObjectForKey:archiveReloginInfo];
            
//            [aDecoder finishDecoding];
//        }
        
        if ([self.deviceId length] == 0)
        {
            self.deviceId = [Utility getGUIDstring];
//            NSMutableData *data = [NSMutableData data];
//            NSKeyedArchiver *aCoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//            [aCoder encodeObject:self.deviceId forKey:archiveDeviceId];
//            [aCoder finishEncoding];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.deviceId forKey:keyOpenPeerUser];
        }
        
//        if (!self.dictionaryIdentities)
//            self.dictionaryIdentities = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString*) fullName
{
    if ([_fullName length] == 0)
    {
        HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
        if (homeUser)
            _fullName = ((HOPAssociatedIdentity*)[homeUser.associatedIdentities anyObject]).homeUserProfile.name;
    }
    return _fullName;
}
/**
 Saves user information on local device.
 */
/*- (void) saveUserData
{
    //self.userId = [[HOPAccount sharedAccount] getUserID];
    //self.stableUniqueId = [[HOPContact getForSelf] getStableUniqueID];
//    self.peerURI = [[HOPContact getForSelf] getPeerURI];
//    self.privatePeerFile = [[HOPAccount sharedAccount] getPeerFilePrivate];
//    self.privatePeerFileSecret = [[HOPAccount sharedAccount] getPeerFilePrivateSecret];
//    self.reloginInfo = [[HOPAccount sharedAccount] getReloginInformation];
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *aCoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [aCoder encodeObject:self.deviceId forKey:archiveDeviceId];
    [aCoder encodeObject:self.stableUniqueId forKey:archiveStableUniqueId];
    [aCoder encodeObject:self.identityURI forKey:archiveIdentityURI];
    [aCoder encodeObject:self.peerURI forKey:archivePeerURI];
    [aCoder encodeObject:self.fullName forKey:archivePasswordNonce];
    [aCoder encodeObject:self.privatePeerFile forKey:archivePrivatePeerFile];
    [aCoder encodeObject:self.privatePeerFileSecret forKey:archivePrivatePeerFileSecret];
    [aCoder encodeObject:self.dictionaryIdentities forKey:archiveAssociatedIdentities];
    [aCoder encodeObject:self.reloginInfo forKey:archiveReloginInfo];
    
    [aCoder finishEncoding];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:keyOpenPeerUser];
}
*/
/**
 deletes user information from local device.
 */
/*
- (void) deleteUserData
{
    //self.userId = nil;
    self.privatePeerFile = nil;
    self.privatePeerFileSecret = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyOpenPeerUser];
}

- (void) addIdentityURI:(NSString*) inIdentityURI forBaseIdentityURI:(NSString*) inBaseIdentity
{
    [self.dictionaryIdentities setObject:inIdentityURI forKey:inBaseIdentity];
}

- (NSString*) createProfileBundle
{
    NSString* ret = nil;
    
    XMLWriter *xmlWriter = [[XMLWriter alloc] init];
    [xmlWriter writeStartElement:profileXmlTagProfile];
    
    [xmlWriter writeStartElement:profileXmlTagName];
    [xmlWriter writeCharacters:self.fullName];
    [xmlWriter writeEndElement];
    
//    [xmlWriter writeStartElement:profileXmlTagContactID];
//    [xmlWriter writeCharacters:self.contactId];
//    [xmlWriter writeEndElement];
    
//    [xmlWriter writeStartElement:profileXmlTagUserID];
//    [xmlWriter writeCharacters:self.userId];
//    [xmlWriter writeEndElement];
    
    [xmlWriter writeStartElement:profileXmlTagIdentities];

    //Temporary not in use
 //
    for (NSString* key in [self.associatedIdentities allKeys])
    {
        [xmlWriter writeStartElement:profileXmlTagIdentityBundle];
        
            [xmlWriter writeStartElement:profileXmlTagIdentity];
            [xmlWriter writeCharacters:key];
            [xmlWriter writeEndElement];
            
            [xmlWriter writeStartElement:profileXmlTagSocialId];
            [xmlWriter writeCharacters:[self.associatedIdentities objectForKey:key]];
            [xmlWriter writeEndElement];
        
        [xmlWriter writeEndElement];
    }
 //
    [xmlWriter writeEndElement];
    
    [xmlWriter writeEndElement];
    
    ret = [NSString stringWithString: [xmlWriter toString]];
    return ret;
}*/
@end
