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

#import "SessionViewController_iPhone.h"
#import "Session.h"
#import "SessionManager.h"
#import "ChatViewController.h"
#import "AudioCallViewController.h"
#import "VideoCallViewController.h"
#import "IncomingCallViewController.h"
#import "WaitingVideoViewController.h"
#import "Utility.h"
#import <OpenPeerSDK/HOPCall.h>

@interface SessionViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UIView* containerView;
@property (nonatomic, strong) IncomingCallViewController* incomingCallViewController;
//It is set to strong because during life cycle it will be situations when this constrain will be removed from self.view. (e.g. showing keyboard)
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomViewContainer;

@property (nonatomic, strong)  NSLayoutConstraint *constraintHeightViewContainer;
@property (nonatomic, strong)  UILabel* labelTitle;
@property (nonatomic, strong)  UILabel* labelDuration;
@property (nonatomic, strong) NSTimer* callTimer;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic) int callDuration;
- (void) actionCallMenu;
-(void)updateCallDuration;
@end

@implementation SessionViewController_iPhone


- (NSLayoutConstraint *)constraintHeightViewContainer
{
    if (!_constraintHeightViewContainer)
    {
        _constraintHeightViewContainer = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.view.frame.size.height];
    }
    
    
    return _constraintHeightViewContainer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithSession:(Session*) inSession
{
    self = [self initWithNibName:@"SessionViewController_iPhone" bundle:nil];
    if (self)
    {
        self.session = inSession;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.chatViewController = [[ChatViewController alloc] initWithSession:self.session];
    self.chatViewController.delegate = self;
    
    [self.chatViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.containerView addSubview:self.chatViewController.view];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.chatViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.chatViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.chatViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.chatViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    // Lightning button
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setImage:[UIImage imageNamed:@"iPhone_lightning_bolt.png"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(actionCallMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    UIBarButtonItem *navBarMenuButton = [[UIBarButtonItem alloc] initWithCustomView: self.menuButton];
    self.navigationItem.rightBarButtonItem = navBarMenuButton;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"iPhone_back_button.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    UIView* titleView = [[ UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 44.0)];
    titleView.backgroundColor = [UIColor clearColor];
    
    self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 3.0, 180.0, 24.0)];
    self.labelTitle.text = [[[self.session participantsArray]objectAtIndex:0] name];
    [self.labelTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.0]];
    self.labelTitle.textColor = [UIColor whiteColor];
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    
    self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 26.0, 160.0, 16.0)];
    [self.labelDuration setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    self.labelDuration.textColor = [UIColor whiteColor];
    //self.labelDuration.text = @"Duration: 00:00:00";
    self.labelDuration.textAlignment = NSTextAlignmentCenter;
    
    [titleView addSubview:self.labelTitle];
    [titleView addSubview:self.labelDuration];
    
    [self.navigationItem setTitleView:titleView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    if (self.containerView == self.chatViewController.view.superview)
        [self.chatViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ChatViewControllerDelegate

- (void) prepareForKeyboard:(NSDictionary*) userInfo showKeyboard:(BOOL) showKeyboard
{
    if (showKeyboard)
    {
        NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
        
        self.constraintBottomViewContainer.constant = keyboardFrame.size.height;
        
        if (self.audioCallViewController.view && self.audioCallViewController.view.hidden == NO)
            self.audioCallViewController.view.hidden = YES;
    }
    else
    {
        self.constraintBottomViewContainer.constant = 0;
    }
}

- (void) actionCallMenu
{
    if(self.audioCallViewController != nil && self.audioCallViewController.view.hidden)//&& self.audioCallViewController.isViewLoaded && self.audioCallViewController.view.window)
    {
        [self.chatViewController.messageTextbox resignFirstResponder];
        self.audioCallViewController.view.hidden = NO;
        //[self.audioCallViewController.view removeFromSuperview];
        
    }
    else if(self.videoCallViewController != nil)
    {
        [self.chatViewController.messageTextbox resignFirstResponder];
        self.videoCallViewController.view.hidden = NO;
     }
    else
    {
        //If call is not in progress show action sheet
        if (!self.audioCallViewController)
        {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Call options", @"")
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
            
            NSMutableArray* buttonTitles = [[NSMutableArray alloc] init];
            
            //int i = 0;
            
            [buttonTitles addObject:NSLocalizedString(@"Audio Call", @"")];
            [buttonTitles addObject:NSLocalizedString(@"Video Call", @"")];
            //[buttonTitles addObject:NSLocalizedString(@"Close session", @"")];
            [buttonTitles addObject:NSLocalizedString(@"Cancel", @"")];
            
            if (action)
            {
                for (int i = 0; i < [buttonTitles count]; i++)
                {
                    [action addButtonWithTitle:[buttonTitles objectAtIndex:i]];
                }
                
                [action showFromRect:self.view.frame inView:self.view.superview animated:YES];
            }
        }
//        else //show call controller
//        {
//            [self.chatViewController.messageTextbox resignFirstResponder];
//            //[self.view addSubview:self.audioCallViewController.view];
//            if (self.audioCallViewController.view.hidden == YES)
//                self.audioCallViewController.view.hidden = NO;
//        }
    }
    
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSLog(@"index: %d", buttonIndex);
    
    switch (buttonIndex)
    {
        case 0:
            [self startAudioSession:NO];
            break;
        case 1:
            //[self startCallWithVideo:YES];
            [self showWaitingView:YES];
            break;
        case 2:
            //[self closeSession:nil];
            break;
        default:
            break;
    }
}

- (void) showWaitingView:(BOOL) show
{
    [self.chatViewController hideKeyboard];
    
    self.waitingVideoViewController = [[WaitingVideoViewController alloc] init];
    [self.waitingVideoViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView addSubview:self.waitingVideoViewController.view];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.waitingVideoViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.waitingVideoViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.waitingVideoViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.waitingVideoViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    [[SessionManager sharedSessionManager] makeCallForSession:self.session includeVideo:YES isRedial:NO];
}
- (void) startCallWithVideo:(BOOL) videoCall
{
    [self.chatViewController hideKeyboard];
    
    CallViewController* callViewController = videoCall ? self.videoCallViewController : self.audioCallViewController;
    
    if (!callViewController)
    {
        if (videoCall)
        {
            self.videoCallViewController = [[VideoCallViewController alloc] initWithSession:self.session];
            callViewController = self.videoCallViewController;
            self.videoCallViewController.delegate = self;
        }
        else
        {
            self.audioCallViewController = [[AudioCallViewController alloc] initWithSession:self.session];
            callViewController = self.audioCallViewController;
        }
        
        [callViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.containerView addSubview:callViewController.view];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:callViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:callViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
        
        if (videoCall)
            [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:callViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        else
            [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:callViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.chatViewController.typingMessageView.frame.size.height]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:callViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    }
    else
    {
        if (callViewController.view.hidden == YES)
            callViewController.view.hidden = NO;
    }
    
    if (videoCall)
    {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIImage* img =[UIImage imageNamed:@"iPhone_Button-end-baritem.png"];
        //[btn setBackgroundImage:img forState:UIControlStateNormal];
        //[btn setImage:img forState:UIControlStateNormal];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.titleLabel.text = @"End";
        [btn addTarget:self action:@selector(actionCallMenu) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(20.0, 0.0, 30.0, 40.0)];
        [btn addTarget:self.videoCallViewController action:@selector(callHangup:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* endCallButton = /*[[UIBarButtonItem alloc] initWithCustomView:btn];*/[[UIBarButtonItem alloc] initWithTitle:@"End" style:UIBarButtonItemStylePlain target:self.videoCallViewController action:@selector(callHangup:)];
        [endCallButton setBackgroundImage:img forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        endCallButton.tintColor = [UIColor whiteColor];
        //endCallButton.width = 30.0;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = endCallButton;

    }
    [callViewController callStarted];
    [[SessionManager sharedSessionManager] makeCallForSession:self.session includeVideo:videoCall isRedial:NO];
}


- (void) updateCallState
{
    NSString *stateStr = [Utility getCallStateAsString:[self.session.currentCall getState]];
    if ([stateStr length] > 0)
        [self.labelDuration setText:stateStr];
}

- (void) showIncomingCall:(BOOL) show
{
    if (show)
    {
        [self.chatViewController hideKeyboard];
        self.incomingCallViewController = [[IncomingCallViewController alloc] initWithSession:self.session];
        [self.incomingCallViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.containerView addSubview:self.incomingCallViewController.view];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.incomingCallViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.incomingCallViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.incomingCallViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.chatViewController.typingMessageView.frame.size.height]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.incomingCallViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    }
    else
    {
        [self.incomingCallViewController.view removeFromSuperview];
    }
}

- (void) removeCallViews
{
    [self showIncomingCall:NO];
    if (self.audioCallViewController && self.audioCallViewController.view)
    {
        [self.audioCallViewController.view removeFromSuperview];
        self.audioCallViewController = nil;
    }
    
    if (self.videoCallViewController && self.videoCallViewController.view)
    {
        [self.videoCallViewController.view removeFromSuperview];
        self.videoCallViewController = nil;
        
        self.navigationItem.rightBarButtonItem = nil;
        UIBarButtonItem *navBarMenuButton = [[UIBarButtonItem alloc] initWithCustomView: self.menuButton];
        self.navigationItem.rightBarButtonItem = navBarMenuButton;
    }
}


- (void)startTimer
{
    self.callDuration = 0;
    [self updateCallDuration];
    self.callTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCallDuration) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [self.callTimer invalidate];
    self.callTimer = nil;
    self.labelDuration.text = @"";
}

-(void)updateCallDuration
{
    self.callDuration++;
    NSInteger secs =    self.callDuration % 60;
    NSInteger mins = (self.callDuration / 60) % 60;
    NSInteger hrs = (self.callDuration / 3600);
    
    self.labelDuration.text = [NSString stringWithFormat:@"%@: %02i:%02i:%02i", NSLocalizedString(@"Duration", @""), hrs, mins, secs];
    
}

- (void) onCallEnded
{
    [self stopTimer];
    [self removeCallViews];
    self.labelDuration.text = @"";
}

#pragma mark - VideoCallViewControllerDelegate
- (void)hideVideo:(BOOL)hide
{
    if (self.videoCallViewController)
        self.videoCallViewController.view.hidden = hide;
}
@end

