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

#import <Foundation/Foundation.h>
#import "HOPTypes.h"

@class HOPContact;
@class HOPRolodexContact;
@class HOPMessage;
@class HOPAccount;
@class HOPIdentity;

//HOP_NOTICE: Don't expose this till group conversations are not enabled
@interface ContactInfo
{
  HOPContact* mContact;
  NSString* mProfileBundleEl;
};

@end

@interface HOPConversationThread : NSObject

/**
*  Creates a new conversation thread.
*
*  @param identities List of identities that are shared with conversation thread participants
*
*  @return HOPConversationThread object
*/
+ (id) conversationThreadWithIdentities:(NSArray*) identities;
/**
 Returns list of all active conversation threads.
 @return List of HOPConversationThread objects
 */
+ (NSArray*) getActiveConversationThreads;

/**
 Returns a conversation thread object for specific thread ID
 @param threadID Conversation thread ID
 @return HOPConversationThread object
 */
+ (HOPConversationThread*) getConversationThreadForID:(NSString*) threadID;

/**
 Returns a string representation of the message delivery state. Deprecated.
 @param state Message delivery state to convert to string
 @return A string representation of message delivery state
 */
+ (NSString*) deliveryStateToString: (HOPConversationThreadMessageDeliveryState) state __attribute__((deprecated("use method stringForMessageDeliveryState instead")));
/**
 Returns a string representation of the message delivery state.
 @param state Message delivery state to convert to string
 @return A string representation of message delivery state
 */
+ (NSString*) stringForMessageDeliveryState:(HOPConversationThreadMessageDeliveryState) state;


/**
 Returns a  string representation of the contact state. Deprecated.
 @param state Contact state to convert to string
 @returns A string representation of contact state
 */
+ (NSString*) stateToString: (HOPConversationThreadContactConnectionState) state __attribute__((deprecated("use method stringForContactConnectionState instead")));
/**
 Returns a  string representation of the contact state.
 @param state Contact state to convert to string
 @return A string representation of contact state
 */
+ (NSString*) stringForContactConnectionState:(HOPConversationThreadContactConnectionState) state;


/**
 Returns a conversation thread ID.
 @return A conversation thread ID
 */
- (NSString*) getThreadId;

/**
 Checks if self is host of the conversation thread.
 @return YES if self is host, NO if not
 */
- (BOOL) amIHost;

/**
 Returns the associated account object.
 @Returns HOPAccount  object
 */
- (HOPAccount*) getAssociatedAccount;

/**
 Returns the array of contacts participating in the conversation thread.
 @returns Array of HOPContact objects
 */
- (NSArray*) getContacts;

/**
 Adds array of contacts to the conversation thread.
 @param contacts  Array of HOPContact objects to be added to the conversation thread
 */
- (void) addContacts: (NSArray*) contacts;

/**
 Removes an array of contacts from the conversation thread.
 @param contacts Array of HOPContact objects to be removed from the conversation thread
 */
- (void) removeContacts: (NSArray*) contacts;

/**
 Returns list of HOPIdentity objects for associated with HOPContact object.
 @param coAn array for HOPIdentity objects
 */
- (NSArray*) getIdentityContactListForContact:(HOPContact*) contact;

/**
 Returns a state of the provided contact.
 @param contact HOPContact object
 @returns Contact state enum
 */
- (HOPConversationThreadContactConnectionState) getContactConnectionState: (HOPContact*) contact;

/**
 *  Get the status of a contact in the conversation thread.
 *
 *  @param contact Contact in the conversation thread
 *
 *  @return Contact status in JSON format
 */
- (NSString*) getContactStatus:(HOPContact*) contact;


//-----------------------------------------------------------------------
// PURPOSE: Set the status of yourself in the conversation thread
// NOTES:   Can use "IConversationThreadComposingStatus" to create
//          composing related contact statuses.

/**
 *  Set the status of yourself in the conversation thread.
 *
 *  @param status         Contact status
 *  @param additionalData Additiona data that will describe user status
 */
- (void) setStatusInThread:(HOPConversationThreadContactStatus) status aditioanlData:(NSString*) additionalData;

/**
 Sends message to all contacts in the conversation thread. Deprecated.
 @param messageID  Message ID
 @param messageType Message type
 @param message Message
 */
- (void) sendMessage: (NSString*) messageID messageType:(NSString*) messageType message:(NSString*) message DEPRECATED_ATTRIBUTE;

/**
 Sends message to all contacts in the conversation thread.
 @param message Message object
 */
- (void) sendMessage: (HOPMessage*) message;

/**
 Returns message for specified message ID. Deprecated.
 @param messageID NSString Received message ID
 @param outFrom HOPContact Message owner contact object
 @param outMessageType NSString Received message type
 @param outMessage NSString Received message
 @param outTime NSDate Received message timestamp
 */
- (BOOL) getMessage: (NSString*) messageID outFrom:(HOPContact**) outFrom outMessageType:(NSString**) outMessageType outMessage:(NSString**) outMessage outTime:(NSDate**) outTime DEPRECATED_ATTRIBUTE;

/**
 Returns message for specified message ID.
 @param messageID  A received message ID
 @return HOPMessage object
 */
- (HOPMessage*) getMessageForID: (NSString*) messageID;

/**
 Retrieves delivery state of the message.
 @param messageID A message ID
 @param outDeliveryState A message delivery state
 @returns YES if delivery state is retrieved, otherwise NO
 */
- (BOOL) getMessageDeliveryState: (NSString*) messageID outDeliveryState:(HOPConversationThreadMessageDeliveryState*) outDeliveryState;

/**
  Destroys conversation thread core object.
 */
- (void) destroyCoreObject;
@end
