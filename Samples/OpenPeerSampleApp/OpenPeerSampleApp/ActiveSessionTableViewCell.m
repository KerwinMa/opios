/*
 
 Copyright (c) 2014, SMB Phone Inc.
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

#import "ActiveSessionTableViewCell.h"
#import "UIBadgeView.h"
#import <OpenPeerSDK/HOPConversationRecord.h>
#import <OpenPeerSDK/HOPMessageRecord.h>
#import <OpenPeerSDK/HOPPublicPeerFile.h>
#import <OpenPeerSDK/HOPModelManager.h>
#import <OpenPeerSDK/HOPRolodexContact.h>
#import <OpenPeerSDK/HOPAvatar.h>
#import <OpenPeerSDK/HOPSystemMessage.h>
#import <OpenPeerSDK/HOPCallSystemMessage.h>
#import <OpenPeerSDK/HOPOpenPeerContact.h>
#import "ImageManager.h"
#import "Session.h"
#import "SessionManager.h"
#import "Utility.h"

@interface ActiveSessionTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *displayName;
@property (nonatomic, weak) IBOutlet UIImageView *displayImage;
@property (nonatomic, weak) IBOutlet UIImageView* displaySessionTypeImage;
@property (nonatomic, weak) IBOutlet UIBadgeView* badgeView;
@property (nonatomic, weak) IBOutlet UILabel *labelCreationDate;
@property (nonatomic, weak) IBOutlet UILabel *labelLastMessage;
@property (nonatomic, weak) IBOutlet UIView *messageView;

@property (nonatomic, weak) HOPConversationRecord* sessionRecord;

@end
@implementation ActiveSessionTableViewCell

- (void)awakeFromNib
{
//    self.messageView.layer.cornerRadius = 5.0;
//    self.messageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.messageView.layer.borderWidth = 1.0;
//    self.messageView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.messageView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLastMessage
{
    self.labelLastMessage.text = [[SessionManager sharedSessionManager] getLastTextMessageForSessionID:self.sessionRecord.sessionID];
    
    self.labelLastMessage.hidden = [self.labelLastMessage.text length] == 0;
}

- (void) setSession:(HOPConversationRecord *)inSessionRecord
{
    self.sessionRecord = inSessionRecord;
    self.displayName.text = self.sessionRecord.name;
    
    HOPOpenPeerContact* contact = [[self.sessionRecord.participants allObjects] objectAtIndex:0];
    
    HOPRolodexContact* participant = [[[HOPModelManager sharedModelManager] getRolodexContactsByPeerURI:contact.publicPeerFile.peerURI] objectAtIndex:0];
    
    UIImage* img = [[ImageManager sharedImageManager] getAvatarImageForRolodexContact:participant];
    if (img)
        self.displayImage.image = img;
    
    self.displayImage.layer.cornerRadius = 5.0;
    self.displayImage.layer.borderWidth = 1.0;
    self.displayImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    Session* session = [[SessionManager sharedSessionManager] getSessionForSessionRecord:self.sessionRecord];
    if ([session.unreadMessageArray count] > 0)
    {
        NSString* numberToDisplay = [NSString stringWithFormat:@"%d",[session.unreadMessageArray count]];
        self.badgeView.hidden = NO;
        self.badgeView.badgeText = numberToDisplay;
    }
    else
    {
        self.badgeView.hidden = YES;
    }
    
    self.labelCreationDate.text = [Utility stringFromDate:inSessionRecord.lastActivity];
    [self setLastMessage];
    //[self drawInnerShadowOnView:self.messageView];
    //[self drawBackground];
}

-(void)drawInnerShadowOnView:(UIView *)view
{
    UIImageView *innerShadowView = [[UIImageView alloc] initWithFrame:view.bounds];
    
    innerShadowView.contentMode = UIViewContentModeScaleToFill;
    innerShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [view addSubview:innerShadowView];
    
    [innerShadowView.layer setMasksToBounds:YES];
    
    [innerShadowView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [innerShadowView.layer setShadowColor:[UIColor blackColor].CGColor];
    [innerShadowView.layer setBorderWidth:1.0f];
    
    [innerShadowView.layer setShadowOffset:CGSizeMake(0, 0)];
    [innerShadowView.layer setShadowOpacity:1.0];
    
    [innerShadowView.layer setCornerRadius:5.0];
    
    // this is the inner shadow thickness
    [innerShadowView.layer setShadowRadius:1.5];
}

- (void) setBackground
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = self.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1] CGColor], nil];
    
    [self setBackgroundView:[[UIView alloc] init]];
    [self.backgroundView.layer insertSublayer:grad atIndex:0];
    
    /*CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = self.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    [self setSelectedBackgroundView:[[UIView alloc] init]];
    [self.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];*/
    
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tableViewCell_selected.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
}

- (void) updateActivity
{
    self.labelCreationDate.text = [Utility stringFromDate:self.sessionRecord.lastActivity];
    [self setLastMessage];
}
@end
