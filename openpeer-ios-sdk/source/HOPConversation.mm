/*
 
 Copyright (c) 2014, Hookflash Inc.
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

#import <openpeer/core/types.h>
#import <openpeer/core/IConversationThread.h>
#import "OpenPeerStorageManager.h"

#import "HOPConversation.h"
#import "HOPAccount.h"
#import "HOPOpenPeerContact+External.h"

#import "HOPConversationThread.h"
#import "HOPConversationRecord.h"
#import "HOPConversationEvent+External.h"
#import "HOPConversationType.h"

#import "HOPRolodexContact+External.h"
#import "HOPMessageRecord+External.h"
#import "HOPModelManager_Internal.h"
#import "HOPUtility.h"
#import "HOPAccount.h"
#import "HOPsettings.h"

ZS_DECLARE_SUBSYSTEM(openpeer_sdk)

using namespace openpeer;
using namespace openpeer::core;

@interface HOPConversation()



@property (nonatomic, strong) NSDictionary* participantsDict;

@property (nonatomic, copy) NSString* identifier;

//- (String) log:(NSString*) message;

@end

@implementation HOPConversation


- (id) init
{
    self = [super init];
    if (self)
    {
        self.identifier = [HOPUtility getGUIDstring];
        self.setOfNotSentMessages = [NSMutableSet new];
        self.numberOfUnreadMessages = 0;
        self.redialCall = NO;
        self.conversationType = [[HOPSettings sharedSettings] getDefaultCovnersationType];
    }
    return self;
}


+ (HOPConversation*) createConversationWithParticipants:(NSArray*) participants title:(NSString*) inTitle type:(HOPConversationThreadType) type
{
    HOPConversation* ret = [HOPConversation new];
    
    if (ret)
    {
        ret.conversationType = type;
        
        ret.thread = [HOPConversationThread conversationThreadWithIdentities:[[HOPAccount sharedAccount] getAssociatedIdentities] participants:participants conversationThreadID: @"" threadType:type];
        
        if (ret.thread)
        {
            ret.title = inTitle.length > 0 ? inTitle : [ret getDefaultTitle];
            
            if (type == HOPConversationThreadTypeContactBased)
                ret.record = [[HOPModelManager sharedModelManager] getConversationRecordForParticipants:participants];
            
            if (!ret.record)
                ret.record = [[HOPModelManager sharedModelManager] createConversationRecordForConversationThread:ret.thread type:[HOPConversationType stringForConversationThreadType:type] date:[NSDate date] name:ret.title participants:participants];
            
            ret.identifier = ret.record.sessionID;
            ret.lastEvent = [[HOPModelManager sharedModelManager] addConversationEvent:@"create" conversationRecord:ret.record partcipants:participants title:ret.title];
            
            NSString* str = [NSString stringWithFormat:@"Conversation object with title %@", ret.title];
            ZS_LOG(Debug, [ret log:str]);
            
            ret.participantsDict = [NSDictionary dictionaryWithObject:participants forKey:ret.lastEvent.eventID];
            
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret threadID:[ret.thread getThreadId]];
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret conversationID:ret.record.sessionID];
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret cbcID:[HOPConversation getCBCIDForContacts:participants]];
        }
        else
        {
            ZS_LOG_ERROR(Debug, [ret log:@"Invalid conversation thread object!"]);
            ret = nil;
        }
    }
    return ret;
}

+ (HOPConversation*) createConversationWithThread:(HOPConversationThread*) inConversationThread
{
    HOPConversation* ret = [HOPConversation new];
    
    if (ret)
    {
        ret.thread = inConversationThread;
        ret.conversationType = inConversationThread.conversationType;
        if (ret.thread)
        {
            ret.title = [ret getDefaultTitle];
            
            NSArray* participants = [ret getParticipants];
            
            ret.record = [[HOPModelManager sharedModelManager] getConversationRecordForConversationThread:inConversationThread];
            
            if (!ret.record)
                ret.record = [[HOPModelManager sharedModelManager] createConversationRecordForConversationThread:ret.thread type:[HOPConversationType stringForConversationThreadType: ret.thread.conversationType] date:[NSDate date] name:ret.title participants:participants];

            ret.identifier = ret.record.sessionID;
            ret.lastEvent = [[HOPModelManager sharedModelManager] addConversationEvent:@"create" conversationRecord:ret.record partcipants:participants title:ret.title];
            
            NSString* str = [NSString stringWithFormat:@"Conversation object with title %@", ret.title];
            ZS_LOG(Debug, [ret log:str]);
            
            ret.participantsDict = [NSDictionary dictionaryWithObject:participants forKey:ret.lastEvent.eventID];
            
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret threadID:[ret.thread getThreadId]];
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret conversationID:ret.record.sessionID];
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret cbcID:[HOPConversation getCBCIDForContacts:participants]];
        }
        else
        {
            ZS_LOG_ERROR(Debug, [ret log:@"Invalid conversation thread object!"]);
            ret = nil;
        }
    }
    return ret;
}

+ (HOPConversation*) createConversationForRecord:(HOPConversationRecord*) inConversationRecord
{
    HOPConversation* ret = [HOPConversation new];
    
    if (ret)
    {
        ret.record = inConversationRecord;
        if (ret.record)
        {
            ret.identifier = ret.record.sessionID;
            ret.title = ret.record.name;
            ret.conversationType = [HOPConversationType conversationThreadTypeForString: ret.record.type];
            
            NSMutableArray* tempParticipants = [NSMutableArray new];
            for (HOPOpenPeerContact* contact in ret.record.participants)
            {
                [tempParticipants addObject:[contact getDefaultRolodexContact]];
            }

            ret.thread = [HOPConversationThread conversationThreadWithIdentities:[[HOPAccount sharedAccount] getAssociatedIdentities] participants:tempParticipants conversationThreadID: inConversationRecord.sessionID threadType:[HOPConversationType conversationThreadTypeForString:inConversationRecord.type]];
            
            ret.lastEvent = [[HOPModelManager sharedModelManager] addConversationEvent:@"create" conversationRecord:ret.record partcipants:tempParticipants title:ret.title];
            
            NSString* str = [NSString stringWithFormat:@"Conversation object with title %@", ret.title];
            ZS_LOG(Debug, [ret log:str]);
            
            ret.participantsDict = [NSDictionary dictionaryWithObject:tempParticipants forKey:ret.lastEvent.eventID];
            
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret threadID:[ret.thread getThreadId]];
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret conversationID:ret.record.sessionID];
            [[OpenPeerStorageManager sharedStorageManager] setConversation:ret cbcID:[HOPConversation getCBCIDForContacts:tempParticipants]];
        }
        else
        {
            ZS_LOG_ERROR(Debug, [ret log:@"Invalid conversation thread object!"]);
            ret = nil;
        }
    }
    return ret;
}

+ (NSString*) getCBCIDForContacts:(NSArray*) contacts
{
    NSString* ret = @"";
    
    for (HOPRolodexContact* contact in contacts)
    {
        if (ret.length == 0)
            ret = [contact getStableID];
        else
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@"_%@",[contact getStableID]]];
    }
    
    return ret;
}

- (void) setComposingStatus:(HOPConversationThreadContactStatus) composingStatus
{
    [self.thread setStatusInThread:composingStatus];
}
- (NSArray*) getParticipants
{
    NSArray* ret = [self.thread getContacts];
    return ret;
}

- (void) refresh
{
    self.thread = nil;
    self.thread = [HOPConversationThread conversationThreadWithIdentities:[[HOPAccount sharedAccount] getAssociatedIdentities]];
    [self.thread addContacts:self.participants];
}


- (void) clear
{
    if (self.thread)
        [self.thread destroyCoreObject];
}

- (HOPConversationThreadContactStatus) getContactStatus:(HOPRolodexContact*) rolodexContact
{
    HOPConversationThreadContactStatus ret = HOPComposingStateInactive;
    
    if (self.thread)
    {
        ret = [self.thread getContactStatus:rolodexContact];
    }
    
    return ret;
}

- (HOPMessageRecord*) getMessageForID: (NSString*) messageID
{
    HOPMessageRecord* ret = nil;
    
    if (self.thread && messageID.length > 0)
        ret = [self.thread getMessageForID:messageID];
    
    return ret;
}

- (void) sendMessage: (HOPMessageRecord*) message
{
    if (self.thread && message)
        [self.thread sendMessage:message];
}

- (void) markAllMessagesRead;
{
    if (self.thread)
        [self.thread markAllMessagesRead];
}
- (NSString*) getID
{
    return self.identifier;
}

- (NSString*) getDefaultTitle
{
    NSString* ret = @"";
    
    NSArray* participants = [self.thread getContacts];
    ret = [HOPConversation getDefaultTitleForParticipants:participants];
    return ret;
}

+(NSString*) getDefaultTitleForParticipants:(NSArray*) inParticipants
{
    NSString* ret = @"";
    
    for (HOPRolodexContact* rolodexContact in inParticipants)
    {
        if (rolodexContact)
        {
            if (ret.length == 0)
                ret = rolodexContact.name;
            else
            {
                ret = [ret stringByAppendingString:@", "];
                ret = [ret stringByAppendingString:rolodexContact.name];
            }
        }
    }
    return ret;
}

+ (NSString*) stringForMessageDeliveryState:(HOPConversationThreadMessageDeliveryState) state
{
    return [HOPConversationThread stringForMessageDeliveryState:state];
}

+ (NSString*) stringForContactConnectionState:(HOPConversationThreadContactConnectionState) state
{
    return [HOPConversationThread stringForContactConnectionState:state];
}

+ (NSString*) stringForConversationThreadType:(HOPConversationThreadType) type
{
    return [HOPConversationType stringForConversationThreadType:type];
}

+ (HOPConversationThreadType) conversationThreadTypeForString:(NSString*) type
{
    return [HOPConversationType conversationThreadTypeForString:type];
}
- (String) log:(NSString*) message
{
    return String("HOPConversation: ") + [message UTF8String];
}

+ (HOPConversation*) conversationOnParticipantsAdded:(NSArray*) addedParticipants conversation:(HOPConversation*) conversation
{
    HOPConversation* ret = nil;
    
    if (conversation.conversationType == HOPConversationThreadTypeContactBased)
    {
        if(addedParticipants.count > 0)
        {
            NSMutableArray* allParticipants = [NSMutableArray arrayWithArray:conversation.participants];
            [allParticipants addObjectsFromArray:addedParticipants];
            
            if ([[HOPSettings sharedSettings] getDefaultCovnersationType] == HOPConversationThreadTypeContactBased)
                ret = [[OpenPeerStorageManager sharedStorageManager] getConversationForCBCID:[HOPConversation getCBCIDForContacts:allParticipants]];
            
            if (!ret)
                ret = [HOPConversation createConversationWithParticipants:allParticipants title:[HOPConversation getDefaultTitleForParticipants:allParticipants] type:[[HOPSettings sharedSettings] getDefaultCovnersationType]];
        }
    }
    else if (conversation.conversationType == HOPConversationThreadTypeThreadBased)
    {
        if (conversation.thread && addedParticipants.count > 0)
        {
            [conversation.thread addContacts:addedParticipants];
            for (HOPRolodexContact* rolodexContact in addedParticipants)
            {
                HOPOpenPeerContact* participant = rolodexContact.openPeerContact;
                if (participant)
                    [conversation.record addParticipantsObject:participant];
            }
        }
        ret = conversation;
    }
    
    if (ret)
    {
        conversation.record.name = [HOPConversation getDefaultTitleForParticipants:conversation.participants];
        conversation.title = conversation.record.name;
        
        conversation.lastEvent = [[HOPModelManager sharedModelManager] addConversationEvent:@"addedParticipant" conversationRecord:conversation.record partcipants:conversation.participants title:conversation.title];
        
        [[HOPModelManager sharedModelManager] saveContext];
    }
    
    return ret;
}

+ (HOPConversation*) conversationOnParticipantsRemoved:(NSArray*) removedParticipants conversation:(HOPConversation*) conversation
{
    HOPConversation* ret = nil;
    
    if (conversation.participants.count >= removedParticipants.count)
    {
        if (conversation.conversationType == HOPConversationThreadTypeContactBased)
        {
            if(removedParticipants.count > 0)
            {
                NSMutableArray* allParticipants = [NSMutableArray arrayWithArray:conversation.participants];
                [allParticipants removeObjectsInArray:removedParticipants];
                
                if ([[HOPSettings sharedSettings] getDefaultCovnersationType] == HOPConversationThreadTypeContactBased)
                    ret = [[OpenPeerStorageManager sharedStorageManager] getConversationForCBCID:[HOPConversation getCBCIDForContacts:allParticipants]];
                
                if (!ret)
                    ret = [HOPConversation createConversationWithParticipants:allParticipants title:[HOPConversation getDefaultTitleForParticipants:allParticipants] type:[[HOPSettings sharedSettings] getDefaultCovnersationType]];
            }
        }
        else if (conversation.conversationType == HOPConversationThreadTypeThreadBased)
        {
            if (conversation.thread && removedParticipants.count > 0)
            {
                [conversation.thread removeContacts:removedParticipants];
            }
            
            for (HOPRolodexContact* rolodexContact in removedParticipants)
            {
                HOPOpenPeerContact* participant = rolodexContact.openPeerContact;
                if (participant)
                    [conversation.record removeParticipantsObject:participant];
            }
            
            ret = conversation;
        }
    }
    else
    {
        ret = conversation; //If number of removed participants is equal or greater than number of active partcipants, do nothing.
    }
    
    
    if (ret)
    {
        conversation.record.name = [HOPConversation getDefaultTitleForParticipants:conversation.participants];
        conversation.title = conversation.record.name;
        
        conversation.lastEvent = [[HOPModelManager sharedModelManager] addConversationEvent:@"removedParticipant" conversationRecord:conversation.record partcipants:conversation.participants title:conversation.title];
        
        [[HOPModelManager sharedModelManager] saveContext];
    }
    return ret;
}

+ (HOPConversation*) getConversationForCBCID:(NSString*) cbcID
{
    return [[OpenPeerStorageManager sharedStorageManager] getConversationForCBCID:cbcID];
}

- (BOOL) removeSelf
{
    BOOL ret = NO;
    if (self.participants.count > 1)
    {
        self.record.selfRemoved = [NSNumber numberWithBool:YES];
        [self.thread removeContacts:@[[HOPRolodexContact getSelf]]];
        [self.thread destroyCoreObject];
        ret = YES;
        [[HOPModelManager sharedModelManager] saveContext];

    }
    
    return ret;
}

- (void) onRemovalTimerExpired:(id) object
{
    @synchronized(self)
    {
        [self.removalTimer invalidate];
        self.removalTimer = nil;
        self.previousParticipants = nil;
    }
}
@end