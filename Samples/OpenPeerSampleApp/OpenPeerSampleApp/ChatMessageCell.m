/*
 
 Copyright (c) 2013, SMB Phone Inc.
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

#import "ChatMessageCell.h"
#import "Message.h"
//#import "OpenPeerUser.h"
#import <OpenpeerSDK/HOPRolodexContact+External.h>
#import <OpenpeerSDK/HOPModelManager.h>
#import <OpenpeerSDK/HOPAvatar.h>
#import <OpenpeerSDK/HOPImage.h>
#import <OpenpeerSDK/HOPHomeUser+External.h>
#import <OpenpeerSDK/HOPMessageRecord.h>
#import <OpenpeerSDK/HOPPublicPeerFile.h>
#import <OpenpeerSDK/HOPIdentityContact.h>
#import "TTTAttributedLabel.h"
#import "Utility.h"

#define AVATAR_WIDTH 10//31
#define AVATAR_HEIGHT 31
#define SPACE_BETWEEN_LABELS 2.0
#define TRAILING_SPACE 10.0
#define LEADING_SPACE 10.0
#define TOP_SPACE 2.0

@interface ChatMessageCell()

@property (nonatomic, strong) UIFont *chatNameFont;
@property (nonatomic, strong) UIFont *chatTimestampFont;
@property (nonatomic, strong) NSString *unicodeMessageText;


- (void) setUnicodeChars:(NSString *)str;

@end

@implementation ChatMessageCell

@synthesize message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        self.chatNameFont =  [UIFont fontWithName:@"Helvetica-Bold" size:9.0];
        self.chatTimestampFont = [UIFont fontWithName:@"Helvetica" size:9.0];
        self.messageLabel = [[TTTAttributedLabel alloc] init];
    }
    return self;
}

-(void)setUnicodeChars:(NSString *)str
{
    // replace emotions
    if(str != _unicodeMessageText)
    {
        _unicodeMessageText = nil;
        
        NSMutableString *ms1 = [[NSMutableString alloc] initWithString:str];
        
        [ms1 replaceOccurrencesOfString:@":)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":]" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"=)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@";)" withString:@"\ue405" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";=)" withString:@"\ue405" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";-)" withString:@"\ue405" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":D" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-D" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=D" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":d" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-d" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=d" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":(" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-(" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":[" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=(" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@";(" withString:@"\ue413" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";-(" withString:@"\ue413" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";=(" withString:@"\ue413" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":o" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-o" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=o" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":O" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-O" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=O" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":*" withString:@"\ue418" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=*" withString:@"\ue418" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-*" withString:@"\ue418" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":p" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-p" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=p" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":P" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-P" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=P" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":$" withString:@"\ue414" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-$" withString:@"\ue414" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=$" withString:@"\ue414" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"|-)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"I-)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"I=)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(snooze)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"|(" withString:@"\ue40e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"|-(" withString:@"\ue40e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"|=(" withString:@"\ue40e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(inlove)" withString:@"\ue106" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":&" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-&" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=&" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(puke)" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":@" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-@" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=@" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"x(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"x-(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"x=(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"X(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"X-(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"X=(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(party)" withString:@"\ue312" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(call)" withString:@"\ue009" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(devil)" withString:@"\ue11a" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(wait)" withString:@"\ue012" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(clap)" withString:@"\ue41f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(rofl)" withString:@"\ue412" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(happy)" withString:@"\ue056" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(punch)" withString:@"\ue00d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(y)" withString:@"\ue00e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(Y)" withString:@"\ue00e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(ok)" withString:@"\ue00e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(n)" withString:@"\ue421" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(N)" withString:@"\ue421" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(handshake)" withString:@"\ue420" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(h)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(H)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(l)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(L)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(u)" withString:@"\ue023" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(U)" withString:@"\ue023" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(e)" withString:@"\ue103" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(m)" withString:@"\ue103" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(f)" withString:@"\ue305" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(F)" withString:@"\ue305" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(rain)" withString:@"\ue331" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(london)" withString:@"\ue331" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(sun)" withString:@"\ue04a" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(music)" withString:@"\ue03e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(coffee)" withString:@"\ue045" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(beer)" withString:@"\ue047" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(cash)" withString:@"\ue12f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(mo)" withString:@"\ue12f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"($)" withString:@"\ue12f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(muscle)" withString:@"\ue14c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(flex)" withString:@"\ue14c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(^)" withString:@"\ue34b" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(cake)" withString:@"\ue34b" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(d)" withString:@"\ue044" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(D)" withString:@"\ue044" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(*)" withString:@"\ue32f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(smoking)" withString:@"\ue30e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(smoke)" withString:@"\ue30e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(ci)" withString:@"\ue30e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        _unicodeMessageText = [NSString stringWithString:ms1];
        //OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelInsane, @"******************setUnicodeChars: _unicodeMessageText:%@",_unicodeMessageText);
    }
}


-(void)layoutSubviews
{
    BOOL isHomeUserSender = !self.message.fromPeer;
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentView.frame = self.bounds;
    
    if (self.message)
    {
        if ([self.message.text length] > 0)
        {
            CGSize messageSize;
            CGSize participantNameSize;
            CGSize dateSize;
            
            float labelHeight;
            float headerLabelXpos = TRAILING_SPACE;
            float bubbleXpos = TRAILING_SPACE;//45.0;
            float avatarXpos = TRAILING_SPACE;
            
            NSString *messageSenderName;
            
            
            [self setUnicodeChars:self.message.text];
            
            if (!self.message.deleted.boolValue)
                messageSize = [ChatCell calcMessageHeight:_unicodeMessageText forScreenWidth:(self.frame.size.width - (2*AVATAR_WIDTH + LEADING_SPACE + TRAILING_SPACE))];
            else
                messageSize = [ChatCell calcMessageHeight:stringDeletedeMessageText forScreenWidth:(self.frame.size.width - (2*AVATAR_WIDTH + LEADING_SPACE + TRAILING_SPACE))];
            
            //if message is received
            if (!isHomeUserSender)
            {
                HOPRolodexContact* contact = ((HOPIdentityContact*)[self.message.fromPeer.identityContacts anyObject]).rolodexContact;
                messageSenderName = [contact name];
//                messageSenderName = [self.message.contact name];
            }
            else
            {
                messageSenderName = [[[HOPModelManager sharedModelManager] getLastLoggedInHomeUser] getFullName];
            }
            
            UIColor* textColor;
            
            if (!self.message.deleted.boolValue)
                textColor = [UIColor whiteColor];
            else
                textColor = [UIColor grayColor];
            
            //Label participant
            participantNameSize = [messageSenderName sizeWithAttributes:@{NSFontAttributeName:self.chatNameFont}];//[messageSenderName sizeWithFont:self.chatNameFont];
            labelHeight = participantNameSize.height + TOP_SPACE;
            UILabel *labelParticipant = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelXpos, TOP_SPACE, participantNameSize.width + SPACE_BETWEEN_LABELS, labelHeight)];
            labelParticipant.backgroundColor = [UIColor clearColor];
            labelParticipant.textColor = textColor;
            labelParticipant.font = self.chatNameFont;
            labelParticipant.text = messageSenderName;
            
            headerLabelXpos += labelParticipant.frame.size.width;
            
            //Label separator
            UILabel *labelSeparator = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelXpos, TOP_SPACE, 10.0, labelHeight)];
            labelSeparator.backgroundColor =[UIColor clearColor];
            labelSeparator.textColor = [UIColor whiteColor];
            labelSeparator.textAlignment = NSTextAlignmentCenter;
            labelSeparator.font = self.chatTimestampFont;
            labelSeparator.text = @" | ";
            
            headerLabelXpos += labelSeparator.frame.size.width;
            
            // Label date
            NSString* formatedDate = [Utility formatedMessageTimeStampForDate:self.message.date];
            dateSize = [formatedDate sizeWithAttributes:@{NSFontAttributeName:self.chatNameFont}];//[formatedDate sizeWithFont:self.chatTimestampFont];
            UILabel *lblChatMessageTimestamp = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelXpos, TOP_SPACE, dateSize.width + TRAILING_SPACE, labelHeight)];
            
            lblChatMessageTimestamp.textColor = textColor;
            
            lblChatMessageTimestamp.backgroundColor = [UIColor clearColor];
            lblChatMessageTimestamp.font = self.chatTimestampFont;
            lblChatMessageTimestamp.text = formatedDate;
            
            NSInteger streachCapWidth = 0;
            NSString* imgName = nil;
            UIImage *avat;
            
            static BOOL b = YES;
            b = !b;
            if(isHomeUserSender)
            {
                streachCapWidth = 13;//15;
                // my messages, show them from the right side
                imgName = @"chat_bubble_right.png";
                
                avatarXpos = self.frame.size.width - (AVATAR_WIDTH + TRAILING_SPACE);
                bubbleXpos = self.frame.size.width - (messageSize.width + 2*AVATAR_WIDTH + LEADING_SPACE + TRAILING_SPACE);
                
                // set header labels position
                headerLabelXpos = self.frame.size.width  - lblChatMessageTimestamp.frame.size.width;
                
                CGRect f = lblChatMessageTimestamp.frame;
                f.origin.x = headerLabelXpos;
                lblChatMessageTimestamp.frame = f;
                
                headerLabelXpos -= labelSeparator.frame.size.width;
                
                f = labelSeparator.frame;
                f.origin.x = headerLabelXpos;
                labelSeparator.frame = f;
                
                headerLabelXpos -= labelParticipant.frame.size.width;
                
                f = labelParticipant.frame;
                f.origin.x = headerLabelXpos;
                labelParticipant.frame = f;
                
                f = self.messageLabel.frame;
                f.origin.x = headerLabelXpos;
                self.messageLabel.frame = f;
            }
            else
            {
                streachCapWidth = 38;//25;
                imgName = @"chat_bubble_left.png";
            }
            
            //Label message
//            [_messageLabel setFrame:CGRectMake(bubbleXpos + 15.0, 20.0, messageSize.width + 5.0, messageSize.height)];
            [self.messageLabel setFrame:CGRectMake(bubbleXpos + 15.0, 25.0, messageSize.width + 10.0, messageSize.height)];
            self.messageLabel.dataDetectorTypes = NSTextCheckingTypeLink;
            self.messageLabel.backgroundColor = [UIColor clearColor];
            self.messageLabel.font = [UIFont systemFontOfSize:14.0];
            self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            if (!self.message.deleted.boolValue)
            {
                self.messageLabel.text = _unicodeMessageText;
                self.messageLabel.textColor = [UIColor blackColor];
            }
            else
            {
                self.messageLabel.text = stringDeletedeMessageText;
                self.messageLabel.textColor = textColor;
            }
            
            self.messageLabel.numberOfLines = 0;
            [self.messageLabel sizeToFit];
            
            // show avatar
            if(!isHomeUserSender)
            {
                HOPRolodexContact* contact = ((HOPIdentityContact*)[self.message.fromPeer.identityContacts anyObject]).rolodexContact;
                HOPAvatar* avatar = [contact getAvatarForWidth:@(40.0) height:@(40.0)];
                //HOPAvatar* avatar = [self.message.contact getAvatarForWidth:@(40.0) height:@(40.0)];
                if (avatar && avatar.avatarImage && avatar.avatarImage.image)
                    avat = [UIImage imageWithData: avatar.avatarImage.image];
            }
    
            if (!avat)
                avat = [UIImage imageNamed:@"avatar.png"];
            
//            UIImageView *ivAvat = [[UIImageView alloc] initWithFrame:CGRectMake(avatarXpos, 18, AVATAR_WIDTH, AVATAR_HEIGHT)];
//            ivAvat.clipsToBounds = YES;
//            ivAvat.layer.cornerRadius = 5.0;
//            [ivAvat setImage:avat];
            // set bubble image
//            float baloonViewH = messageSize.height + 8 < 28.0 ? 28.0 : messageSize.height + 8;
            float baloonViewH = messageSize.height + 34 < 52.0 ? 52.0 : messageSize.height + 34;
            
            UIImage *msgBaloonImg = [[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:streachCapWidth topCapHeight:14];
            //UIImage *msgBaloonImg = [[UIImage imageNamed:imgName] resizableImageWithCapInsets:UIEdgeInsetsMake(23, 23, 50, 4)];
            UIImageView *msgBaloonView = [[UIImageView alloc] initWithFrame:CGRectMake(bubbleXpos, 20, messageSize.width + 30, baloonViewH)];
            
            UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            
            
            [msgBaloonView setImage:msgBaloonImg];
            if (!self.message.deleted.boolValue)
                [cellView addSubview:msgBaloonView];
            
            self.backgroundView = cellView;
            //[self.contentView addSubview:ivAvat];
            [self.contentView addSubview:self.messageLabel];
            
            [self.contentView addSubview:labelParticipant];
            [self.contentView addSubview:labelSeparator];
            [self.contentView addSubview:lblChatMessageTimestamp];
            
        }
    }
}

- (void) setMessage:(HOPMessageRecord*) inMessage
{
    message = inMessage;
    
    if (!self.message.deleted.boolValue)
    {
        //self.messageLabel.text = _unicodeMessageText;
        self.messageLabel.textColor = [UIColor blackColor];
    }
    else
    {
        //self.messageLabel.text = stringDeletedeMessageText;
        self.messageLabel.textColor = [UIColor grayColor];
    }
}

@end
