//
// InformationViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "ConferenceViewController.h"
#import "InformationViewController.h"
#import "ooVooController.h"

@implementation InformationViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Information";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidJoin:) name:OOVOOParticipantDidJoinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidChange:) name:OOVOOParticipantVideoStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:OOVOOVideoDidStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOVideoDidStartNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	return [self.participantsController numberOfParticipants];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UISwitch *switcher;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switcher addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switcher;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        switcher = (UISwitch *)cell.accessoryView;
    }
    
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
	cell.textLabel.text = participant.displayName;
    switcher.on = (participant.state == ooVooVideoOn);
    switcher.tag = indexPath.row;
    
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Participants";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Conference ID: %@", self.conferenceId];
}

#pragma mark - Actions
- (void)toggleSwitch:(UISwitch *)aSwitch
{
    BOOL enable = aSwitch.isOn;
    NSUInteger index = aSwitch.tag;
    
    Participant *participant = [self.participantsController participantAtIndex:index];
    participant.state = enable? ooVooVideoOn : ooVooVideoOff;
    [[ooVooController sharedController] receiveParticipantVideo:enable forParticipantID:participant.participantID];
}

#pragma mark - Notifications
- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

- (void)participantDidLeave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });    
}

- (void)participantDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

@end
