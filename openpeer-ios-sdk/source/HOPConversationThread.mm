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


#import <openpeer/core/IConversationThread.h>
#import <openpeer/core/IContact.h>
#import <openpeer/core/IHelper.h>

#import "HOPConversationThread_Internal.h"
#import "HOPContact_Internal.h"
#import "HOPAccount_Internal.h"
#import "HOPMessage.h"

#import "OpenPeerStorageManager.h"
#import "OpenPeerUtility.h"


ZS_DECLARE_SUBSYSTEM(openpeer_sdk)

using namespace openpeer;
using namespace openpeer::core;

@implementation HOPConversationThread

+ (NSArray*) getConversationThreadsForAccount
{
    return [[OpenPeerStorageManager sharedStorageManager] getConversationThreads];
}

+ (HOPConversationThread*) getConversationThreadForID:(NSString*) threadID
{
    HOPConversationThread* ret = nil;
    if (threadID)
        ret =[[OpenPeerStorageManager sharedStorageManager] getConversationThreadForId:threadID];
    return ret;
}

+ (NSString*) deliveryStateToString: (HOPConversationThreadMessageDeliveryStates) state
{
    return [NSString stringWithUTF8String: IConversationThread::toString((IConversationThread::MessageDeliveryStates) state)];
}
+ (NSString*) stringForMessageDeliveryState:(HOPConversationThreadMessageDeliveryStates) state
{
    return [NSString stringWithUTF8String: IConversationThread::toString((IConversationThread::MessageDeliveryStates) state)];
}

+ (NSString*) stateToString: (HOPConversationThreadContactStates) state
{
    return [NSString stringWithUTF8String: IConversationThread::toString((IConversationThread::ContactStates) state)];
}
+ (NSString*) stringForContactState:(HOPConversationThreadContactStates) state
{
    return [NSString stringWithUTF8String: IConversationThread::toString((IConversationThread::ContactStates) state)];
}

- (id)init
{
    [NSException raise:NSInvalidArgumentException format:@"Don't use init for object creation. Use class method conversationThreadWithProfileBundle."];
    return nil;
}

- (id) initWithConversationThread:(IConversationThreadPtr) inConversationThreadPtr
{
    self = [super init];
    if (self)
    {
        conversationThreadPtr = inConversationThreadPtr;
        [[OpenPeerStorageManager sharedStorageManager] setConversationThread:self forId:[NSString stringWithUTF8String:inConversationThreadPtr->getThreadID()]];
    }
    return self;
}

+  (id) conversationThreadWithProfileBundle:(NSString*) profileBundle
{
    HOPConversationThread* ret = nil;
    
    zsLib::XML::ElementPtr elementPtr;
    
    if ([profileBundle length] > 0)
        elementPtr = IHelper::createElement([profileBundle UTF8String]);
    else
        elementPtr = zsLib::XML::ElementPtr();
    
    IConversationThreadPtr tempConversationThreadPtr = IConversationThread::create([[HOPAccount sharedAccount] getAccountPtr], elementPtr);
    
    if (tempConversationThreadPtr)
    {
        ret = [[self alloc] initWithConversationThread:tempConversationThreadPtr];
    }
    return ret;
}

- (NSString*) getThreadId
{
    NSString* threadId = nil;
    
    if(conversationThreadPtr)
    {
        threadId = [NSString stringWithUTF8String: conversationThreadPtr->getThreadID()];
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    return threadId;
}

- (BOOL) amIHost
{
    BOOL ret = NO;
    if (conversationThreadPtr)
    {
        ret = conversationThreadPtr->amIHost();
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    return ret;
}

- (HOPAccount*) getAssociatedAccount
{
    return [HOPAccount sharedAccount];
}

- (NSArray*) getContacts
{
    NSMutableArray* contactArray = nil;
    if (conversationThreadPtr)
    {
        contactArray = [[NSMutableArray alloc] init];
        ContactListPtr contactList = conversationThreadPtr->getContacts();
        
        for (ContactList::iterator contact = contactList->begin(); contact != contactList->end(); ++contact)
        {
            IContactPtr contactPtr = *contact;
            if (!contactPtr->isSelf())
            {
                HOPContact* tempContact = [[OpenPeerStorageManager sharedStorageManager] getContactForPeerURI:[NSString stringWithUTF8String:contactPtr->getPeerURI()]];
                [contactArray addObject:tempContact];
            }
        }
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    
    return contactArray;
}

- (NSString*) getProfileBundle: (HOPContact*) contact
{
    NSString* ret = nil;
    if (conversationThreadPtr)
    {
        ret = [NSString stringWithUTF8String:IHelper::convertToString(conversationThreadPtr->getProfileBundle([contact getContactPtr]))];
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    return ret;
}

- (HOPConversationThreadContactStates) getContactState: (HOPContact*) contact
{
    HOPConversationThreadContactStates ret = HOPConversationThreadContactStateNotApplicable;
    if(conversationThreadPtr)
    {
        ret = (HOPConversationThreadContactStates) conversationThreadPtr->getContactState([contact getContactPtr]);
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    
    return ret;
}

- (void) addContacts: (NSArray*) contacts
{
    if(conversationThreadPtr)
    {
        if ([contacts count] > 0)
        {
            ContactProfileInfoList contactList;
            for (HOPContact* contact in contacts)
            {
                ContactProfileInfo contactInfo;
                contactInfo.mContact = [contact getContactPtr];
                contactInfo.mProfileBundleEl = zsLib::XML::ElementPtr();
                
                contactList.push_back(contactInfo);
            }

            conversationThreadPtr->addContacts(contactList);
        }
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
}

- (void) removeContacts: (NSArray*) contacts
{
    if(conversationThreadPtr)
    {
        if ([contacts count] > 0)
        {
            ContactList contactList;
            for (HOPContact* contact in contacts)
            {
                contactList.push_back([contact getContactPtr]);
            }
            conversationThreadPtr->removeContacts(contactList);
        }
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }

}

- (void) sendMessage: (NSString*) messageID messageType:(NSString*) messageType message:(NSString*) message
{
    if(conversationThreadPtr)
    {
        conversationThreadPtr->sendMessage([messageID UTF8String], [messageType UTF8String], [message UTF8String]);
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
}

- (void) sendMessage: (HOPMessage*) message
{
    if(conversationThreadPtr)
    {
        conversationThreadPtr->sendMessage([message.messageID UTF8String], [message.type UTF8String], [message.text UTF8String]);
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
}

- (HOPMessage*) getMessageForID: (NSString*) messageID
{
    HOPMessage* hopMessage = nil;
    if(conversationThreadPtr)
    {
        IContactPtr fromContact;
        zsLib::String messageType;
        zsLib::String message;
        zsLib::Time messageTime;
        
        conversationThreadPtr->getMessage([messageID UTF8String], fromContact, messageType, message, messageTime);
        
        if (fromContact && messageType && message)
        {
            hopMessage = [[HOPMessage alloc] init];
            
            hopMessage.contact = [[OpenPeerStorageManager sharedStorageManager] getContactForPeerURI:[NSString stringWithUTF8String:fromContact->getPeerURI()]];
            hopMessage.type = [NSString stringWithUTF8String:messageType];
            hopMessage.text = [NSString stringWithUTF8String:message];
            hopMessage.date = [OpenPeerUtility convertPosixTimeToDate:messageTime];
        }
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }

    return hopMessage;
}
- (BOOL) getMessage: (NSString*) messageID outFrom:(HOPContact**) outFrom outMessageType:(NSString**) outMessageType outMessage:(NSString**) outMessage outTime:(NSDate**) outTime
{
    BOOL ret = NO;
    if(conversationThreadPtr)
    {
        IContactPtr fromContact;
        zsLib::String messageType;
        zsLib::String message;
        zsLib::Time messageTime;
    
        conversationThreadPtr->getMessage([messageID UTF8String], fromContact, messageType, message, messageTime);
        
        if (fromContact && messageType && message)
        {
            *outFrom = [[OpenPeerStorageManager sharedStorageManager] getContactForPeerURI:[NSString stringWithUTF8String:fromContact->getPeerURI()]];
            *outMessageType = [NSString stringWithUTF8String:messageType];
            *outMessage = [NSString stringWithUTF8String:message];
            *outTime = [OpenPeerUtility convertPosixTimeToDate:messageTime];
            ret = YES;
        }
        
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    return ret;
}

- (BOOL) getMessageDeliveryState: (NSString*) messageID outDeliveryState:(HOPConversationThreadMessageDeliveryStates*) outDeliveryState
{
    BOOL ret = NO;
    IConversationThread::MessageDeliveryStates tmpState;

    if(conversationThreadPtr)
    {
        if ([messageID length] > 0)
        {
            ret = conversationThreadPtr->getMessageDeliveryState([messageID UTF8String], tmpState);
            *outDeliveryState = (HOPConversationThreadMessageDeliveryStates) tmpState;
        }
    }
    else
    {
        ZS_LOG_ERROR(Debug, [self log:@"Invalid conversation thread object!"]);
        [NSException raise:NSInvalidArgumentException format:@"Invalid conversation thread object!"];
    }
    return ret;
}

- (NSString *)description
{
    return [NSString stringWithUTF8String: IConversationThread::toDebugString([self getConversationThreadPtr],NO)];
}

#pragma mark - Internal methods
- (IConversationThreadPtr) getConversationThreadPtr
{
    return conversationThreadPtr;
}

- (String) log:(NSString*) message
{
    if (conversationThreadPtr)
        return String("HOPConversationThread [") + string(conversationThreadPtr->getID()) + "] " + [message UTF8String];
    else
        return String("HOPConversationThread: ") + [message UTF8String];
}
@end
