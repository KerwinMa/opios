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


#import "HOPContact.h"
#import "HOPAccount_Internal.h"
#import <openpeer/core/IContact.h>
#import <openpeer/core/IAccount.h>
#import <openpeer/core/IHelper.h>
#import "HOPContact_Internal.h"
#import "OpenPeerStorageManager.h"

ZS_DECLARE_SUBSYSTEM(openpeer_sdk)

@implementation HOPContact

- (id)init
{
    [NSException raise:NSInvalidArgumentException format:@"Don't use init for object creation. Use class method contactWithPeerFile."];
    return nil;
}

- (id) initWithCoreContact:(IContactPtr) inContactPtr
{
    self = [super init];
    if (self)
    {
        coreContactPtr = inContactPtr;
        NSString* peerURI = [NSString stringWithCString:coreContactPtr->getPeerURI() encoding:NSUTF8StringEncoding];
        //If there is no stable id, then there is no valid openpeer contact, so stop creation of HOPContact
        if ([peerURI length] > 0)
            [[OpenPeerStorageManager sharedStorageManager] setContact:self forPeerURI:peerURI];
        else
            return nil;
    }
    
    return self;
}

- (id) initWithPeerFile:(NSString*) publicPeerFile
{
    self = [super init];
    
    if (self)
    {
        if ([publicPeerFile length] > 0)
        {
            ElementPtr publicPeerXml = IHelper::createElement([publicPeerFile UTF8String]);
            IPeerFilePublicPtr publicPeer = IHelper::createPeerFilePublic(publicPeerXml);
            
            IContactPtr tempCoreContactPtr = IContact::createFromPeerFilePublic([[HOPAccount sharedAccount] getAccountPtr], publicPeer);
                
                if (tempCoreContactPtr)
                {
                    coreContactPtr = tempCoreContactPtr;
                    [[OpenPeerStorageManager sharedStorageManager] setContact:self forPeerURI:[self getPeerURI]];
                }
        }
        else
        {
            self = nil;
        }
    }

    return self;
}


+ (HOPContact*) getForSelf
{
    HOPContact* ret = nil;
    
    IContactPtr selfContact = IContact::getForSelf([[HOPAccount sharedAccount] getAccountPtr]);
    ret = [[OpenPeerStorageManager sharedStorageManager] getContactForPeerURI:[NSString stringWithCString:selfContact->getPeerURI() encoding:NSUTF8StringEncoding]];
    if (!ret)
        ret = [[HOPContact alloc] initWithCoreContact:selfContact];
    
    return ret;
}

- (BOOL) isSelf
{
    BOOL ret = NO;
    
    if (coreContactPtr)
    {
        ret = coreContactPtr->isSelf();
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid contact object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid contact object!"];
    }
    
    return ret;
}

- (NSString*) getPeerURI
{
    NSString* ret = nil;
    
    if (coreContactPtr)
    {
        ret = [NSString stringWithCString:coreContactPtr->getPeerURI() encoding:NSUTF8StringEncoding];
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid contact object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid contact object!"];
    }
    return ret;
}


- (HOPAccount*) getAssociatedAccount
{
    return [HOPAccount sharedAccount];
}

- (void) hintAboutLocation:(NSString*) contactsLocationID
{
    if (coreContactPtr)
    {
        if ([contactsLocationID length] > 0)
            coreContactPtr->hintAboutLocation([contactsLocationID UTF8String]);
        else
        {
            ZS_LOG_ERROR(Debug, [self log:@"nvalid contacts location ID!"]);
            [NSException raise:NSInvalidArgumentException format:@"Invalid contacts location ID!"];
        }
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid contact object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid contact object!"];
    }
}

-(NSString *)description
{
    return [NSString stringWithUTF8String: IContact::toDebugString([self getContactPtr],NO)];
}


#pragma mark - Internal methods
- (IContactPtr) getContactPtr
{
    return coreContactPtr;
}

- (String) log:(NSString*) message
{
    if (coreContactPtr)
        return String("HOPContact [") + string(coreContactPtr->getID()) + "] " + [message UTF8String];
    else
        return String("HOPContact: ") + [message UTF8String];
}
@end
