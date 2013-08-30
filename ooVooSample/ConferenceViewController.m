//
// ConferenceViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ConferenceViewController.h"
#import "InformationViewController.h"
#import "AlertsViewController.h"
#import "VideoCollectionViewCell.h"
#import "ooVooController.h"

@interface ConferenceViewController () <UIPopoverControllerDelegate>
{
    BOOL mic;
    BOOL speaker;
    BOOL camera;
    NSUInteger currentCamera;
}

@property (nonatomic, copy) NSString *zoomedParticipantID;
@property (nonatomic, strong) ooVooVideoView *fullScreenVideoView;
@property (nonatomic, strong) UIPopoverController *infoPopoverController;
@property (nonatomic, strong) UIPopoverController *alertsPopoverController;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@end

static NSString *kCellIdentifier = @"VIDEO_CELL";

@implementation ConferenceViewController

- (void)dealloc
{
    self.infoPopoverController.delegate = self.alertsPopoverController.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Conference";
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Alerts"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showAlertsView:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Info"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                             action:@selector(navigateToInformation:)];
    
    [self.collectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    speaker = [ooVooController sharedController].speakerEnabled = YES;
    mic = [ooVooController sharedController].microphoneEnabled = YES;
    currentCamera = [ooVooController sharedController].currentCamera;
    [[ooVooController sharedController] setCameraResolutionLevel:2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *micBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_mic"]
                                                             style:mic?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(muteMicPressed:)];
    
    UIBarButtonItem *spkBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_speaker"]
                                                             style:speaker?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(muteSpeakerPressed:)];
    
    UIBarButtonItem *endBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  LEAVE  "
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(endCallButtonPressed:)];
    
    UIBarButtonItem *camBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_camera"]
                                                             style:currentCamera?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(cameraPressed:)];
    
    UIBarButtonItem *resBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self resolutionText]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(resButtonPressed:)];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        [self setToolbarItems:@[flexibleItem, micBarButtonItem, spkBarButtonItem, endBarButtonItem, camBarButtonItem, resBarButtonItem, flexibleItem] animated:NO];
    }
    else
    {
        [self setToolbarItems:@[micBarButtonItem, flexibleItem, spkBarButtonItem, flexibleItem, endBarButtonItem, flexibleItem, camBarButtonItem, flexibleItem, resBarButtonItem] animated:NO];        
    }
    
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
    self.participantsController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.participantsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOParticipantDidLeaveNotification object:nil];
}

#pragma mark - Actions
- (void)navigateToInformation:(id)sender
{
    InformationViewController *infoViewController = [[InformationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoViewController.participantsController = self.participantsController;
    infoViewController.conferenceId = self.conferenceId;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        if (!self.infoPopoverController)
        {
            self.infoPopoverController = [[UIPopoverController alloc] initWithContentViewController:infoViewController];
            self.infoPopoverController.delegate = self;
            [self.infoPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            [self.infoPopoverController dismissPopoverAnimated:YES];
            self.infoPopoverController = nil;
        }
    }
    else
    {
        infoViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:infoViewController animated:YES];        
    }
}

- (void)showAlertsView:(id)sender
{
    AlertsViewController *alertsViewController = [[AlertsViewController alloc] init];
    alertsViewController.logsController = self.logsController;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        if (!self.alertsPopoverController)
        {
            self.alertsPopoverController = [[UIPopoverController alloc] initWithContentViewController:alertsViewController];
            self.alertsPopoverController.delegate = self;
            [self.alertsPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            [self.alertsPopoverController dismissPopoverAnimated:YES];
            self.alertsPopoverController = nil;
        }
    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:alertsViewController];
        [self presentViewController:navigationController animated:YES completion: nil];
    }
}

- (void)endCallButtonPressed:(id)sender
{
    [[ooVooController sharedController] leaveConference];
}

- (void)muteMicPressed:(id)sender
{
    mic = !mic;
    [ooVooController sharedController].microphoneEnabled = mic;
    ((UIBarButtonItem *)sender).style = mic?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone;
}

- (void)muteSpeakerPressed:(id)sender
{    
    speaker = !speaker;
    [ooVooController sharedController].speakerEnabled = speaker;
    ((UIBarButtonItem *)sender).style = speaker?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone;
}

- (void)cameraPressed:(id)sender
{
    currentCamera = !currentCamera;
    [[ooVooController sharedController] selectCamera:currentCamera];
    ((UIBarButtonItem *)sender).style = currentCamera?UIBarButtonItemStyleBordered:UIBarButtonItemStyleDone;
}

- (void)resButtonPressed:(id)sender
{
    ooVooController *ooVoo = [ooVooController sharedController];
    if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionLow)
    {
        [ooVoo setCameraResolutionLevel:ooVooCameraResolutionMedium];
        ((UIBarButtonItem *)sender).title = @"Med";
    }
    else if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionMedium)
    {
        [ooVoo setCameraResolutionLevel:ooVooCameraResolutionLow];
        ((UIBarButtonItem *)sender).title = @"Low";
    }
}

- (NSString*)resolutionText
{
    ooVooController *ooVoo = [ooVooController sharedController];
    NSString* resolutionText = @"";
    if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionLow)
    {
        resolutionText = @"Low";
    }
    else if ([ooVoo cameraResolutionLevel] == ooVooCameraResolutionMedium)
    {
        resolutionText = @"Med";
    }
    
    return resolutionText;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.participantsController numberOfParticipants];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(VideoCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
    cell.avatarImgView.image = [UIImage imageNamed:@"user.png"];
    cell.userNameLabel.text = participant.displayName;

    ooVooVideoView *videoView;
    if ([self.zoomedParticipantID isEqualToString:participant.participantID])
    {
        videoView = self.fullScreenVideoView;
    }
    else
    {
        videoView = cell.videoView;
    }
    
    switch (participant.state)
    {
        case ooVooVideoUninitialized:
            [cell showAvatar];
            [cell hideState];
            [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:participant.participantID];
            break;
        case ooVooVideoOn:
            videoView.supportOrientation = (indexPath.row != 0);
            [videoView associateToID:participant.participantID];
            [cell hideAvatar];
            [cell hideState];
            break;
        case ooVooVideoOff:
            [cell showAvatar];
            [videoView clear];
            [cell hideState];
            if (videoView == self.fullScreenVideoView) { [self zoomOut:nil]; }
            break;
        case ooVooVideoPaused:
            [cell showAvatar];
            [videoView clear];
            [cell showState:@"Video cannot be viewed"];
            if (videoView == self.fullScreenVideoView) { [self zoomOut:nil]; }
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
    [self zoomIn:participant];
}

#pragma mark - ParticipantsControllerDelegate
- (void)controllerWillChangeContent:(ParticipantsController *)controller
{
    self.blockOperation = [NSBlockOperation new];
}

- (void)controller:(ParticipantsController *)controller didChangeParticipant:(Participant *)aParticipant atIndexPath:(NSIndexPath *)indexPath forChangeType:(ParticipantChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;

    switch (type)
    {
        case ParticipantChangeInsert:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView insertItemsAtIndexPaths:@[newIndexPath]]; }];
            break;
        }
            
        case ParticipantChangeDelete:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView deleteItemsAtIndexPaths:@[indexPath]]; }];
            break;
        }
            
        case ParticipantChangeUpdate:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView reloadItemsAtIndexPaths:@[indexPath]]; }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(ParticipantsController *)controller
{
    [self.collectionView performBatchUpdates:^{ [self.blockOperation start]; }
                                      completion:nil];
}

#pragma mark - Zoom
- (void)zoomIn:(Participant *)participant
{
    if (participant.state != ooVooVideoOn) return;
    
    self.zoomedParticipantID = participant.participantID;
    NSUInteger index = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    
    cellRect = [self.collectionView convertRect:cellRect toView:self.view];
    
    self.fullScreenVideoView = [[ooVooVideoView alloc] initWithFrame:cellRect];
    self.fullScreenVideoView.fitVideoMode = NO;
    self.fullScreenVideoView.animateRotation = YES;
    self.fullScreenVideoView.supportOrientation = !(participant.isMe);
    self.fullScreenVideoView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    [self.fullScreenVideoView addGestureRecognizer:singleTapGestureRecognizer];
    
    [self.view addSubview:self.fullScreenVideoView];
    [self.fullScreenVideoView associateToID:self.zoomedParticipantID];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        self.fullScreenVideoView.frame = self.view.frame;
    }];
}

- (void)zoomOut:(UITapGestureRecognizer *)gestureRecognizer
{
    CGRect cellRect = CGRectZero;
    NSUInteger row = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
    
    if (row != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        cellRect = attributes.frame;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        self.fullScreenVideoView.frame = cellRect;
        
    } completion:^(BOOL finished){
        
        if (gestureRecognizer) [self.fullScreenVideoView removeGestureRecognizer:gestureRecognizer];
        [self.fullScreenVideoView clear];
        [self.fullScreenVideoView removeFromSuperview];
        self.fullScreenVideoView = nil;
        
        NSUInteger currentRow = [self.participantsController indexOfParticipantWithId:self.zoomedParticipantID];
        self.zoomedParticipantID = nil;
        
        if (currentRow != NSNotFound)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }];
}

- (void)participantDidLeave:(NSNotification *)notification
{
    CGRect cellRect = CGRectZero;
    NSString *ParticipantID = [notification.userInfo objectForKey:OOVOOParticipantIdKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fullScreenVideoView != nil){
            if ([ParticipantID isEqualToString:self.zoomedParticipantID]){
                [UIView animateWithDuration:0.25 animations:^{
                    
                    [self.navigationController setToolbarHidden:NO animated:YES];
                    [self.navigationController setNavigationBarHidden:NO animated:YES];
                    
                    self.fullScreenVideoView.frame = cellRect;
                    
                } completion:^(BOOL finished){
                    [self.fullScreenVideoView clear];
                    [self.fullScreenVideoView removeFromSuperview];
                    self.zoomedParticipantID = nil;
                    self.fullScreenVideoView = nil;
                }];
            }
        }
    });
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.infoPopoverController)
    {
        self.infoPopoverController = nil;
    }
    else if (popoverController == self.alertsPopoverController)
    {
        self.alertsPopoverController = nil;
    }
}

@end
