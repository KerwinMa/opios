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

#import "ConversationThreadDelegate.h"
#import "SessionManager.h"
#import "ContactsManager.h"
#import "MessageManager.h"

#import <OpenpeerSDK/HOPConversationThread.h>
#import <OpenpeerSDK/HOPContact.h>
#import <OpenpeerSDK/HOPRolodexContact.h>
#import <OpenpeerSDK/HOPMessage.h>
#import <OpenpeerSDK/HOPModelManager.h>

#ifdef APNS_ENABLED
#import "APNSManager.h"
#import <OpenpeerSDK/HOPModelManager.h>
#endif

@implementation ConversationThreadDelegate

- (void) onConversationThreadNew:(HOPConversationThread*) conversationThread
{
    NSLog(@"onConversationThreadNew");
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (conversationThread)
        {
            NSArray* participants = [conversationThread getContacts];
            
            if ([participants count] > 0)
            {
                HOPContact* participant = [participants objectAtIndex:0];
                
                if (![[SessionManager sharedSessionManager] proceedWithExistingSessionForContact:participant newConversationThread:conversationThread])
                {
                    [[SessionManager sharedSessionManager] createSessionForConversationThread: conversationThread];
                }
            }
        }
    });
}
- (void) onConversationThreadContactsChanged:(HOPConversationThread*) conversationThread
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void) onConversationThreadContactStateChanged:(HOPConversationThread*) conversationThread contact:(HOPContact*) contact contactState:(HOPConversationThreadContactStates) contactState
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void) onConversationThreadMessage:(HOPConversationThread*) conversationThread messageID:(NSString*) messageID
{
    NSLog(@"onConversationThreadMessage");
    dispatch_async(dispatch_get_main_queue(), ^{
        HOPMessage* message = [conversationThread getMessageForID:messageID];
        if (message)
        {
            [[MessageManager sharedMessageManager] onMessageReceived:message forSessionId:[conversationThread getThreadId]];
        }
    });
}
- (void) onConversationThreadMessageDeliveryStateChanged:(HOPConversationThread*) conversationThread messageID:(NSString*) messageID messageDeliveryStates:(HOPConversationThreadMessageDeliveryStates) messageDeliveryStates
{
    NSLog(@"onConversationThreadMessageDeliveryStateChanged: %d",messageDeliveryStates);
    
#ifdef APNS_ENABLED
    if (messageDeliveryStates == HOPConversationThreadMessageDeliveryStateUserNotAvailable)
    {
        NSArray* contacts = [conversationThread getContacts];
        if ([contacts count] > 0)
        {
            HOPMessage* message = [conversationThread getMessageForID:messageID];
            HOPContact* coreContact = [contacts objectAtIndex:0];
            if (coreContact)
            {
                HOPRolodexContact* contact  = [[[HOPModelManager sharedModelManager] getRolodexContactsByPeerURI:[coreContact getPeerURI]] objectAtIndex:0];
                if (contact)
                {
                    NSString* messageText  = [NSString stringWithFormat:@"%@ \n %@",[contact name],message.text];
                    [[APNSManager sharedAPNSManager] sendPushNotificationForContact:coreContact message:messageText missedCall:NO];
                }
            }
        }
    }
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
- (void) onConversationThreadPushMessage:(HOPConversationThread*) conversationThread messageID:(NSString*) messageID contact:(HOPContact*) contact
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}
@end
