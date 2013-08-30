//
// MainViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "MainViewController.h"
#import "ConferenceViewController.h"
#import "ConferenceLayout.h"
#import "SettingsViewController.h"
#import "TextFieldCell.h"

#import "ooVooController.h"
#import "ParticipantsController.h"
#import "LogsController.h"

static NSString *kDefaultAppId = @"";
static NSString *kDefaultAppToken = @"";
static NSString *kDefaultConferenceId = @"";

@interface MainViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;
@property (nonatomic, assign) UITextField *currentTextField;

@property (nonatomic, copy) NSString *applicationToken;
@property (nonatomic, copy) NSString *applicationId;
@property (nonatomic, copy) NSString *conferenceId;
@property (nonatomic, copy) NSString *opaqueString;

@end

typedef enum
{
    AppIdRow = 0,
    AppTokenRow,
    ConferenceIdRow,
    DisplayNameRow,
    NUMBER_OF_LOGIN_ROWS
}
LoginRow;

NSString * const kLoginLabelsArray[] =
{
    @"App ID",
    @"App Token",
    @"Conference ID",
    @"Display Name",
};

@implementation MainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ooVoo Sample";
    self.applicationToken = kDefaultAppToken;
    self.applicationId = kDefaultAppId;
    self.conferenceId = kDefaultConferenceId;
    self.opaqueString = @"";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(navigateToSettings)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidBegin:)
                                                 name:OOVOOConferenceDidBeginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidFail:)
                                                 name:OOVOOConferenceDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidEnd:)
                                                 name:OOVOOConferenceDidEndNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.tableView.tableFooterView)
    {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.joinButton.bounds) + 20.0f)];
        [self.tableView.tableFooterView addSubview:self.joinButton];
        [self.tableView.tableFooterView addSubview:self.activityIndicator];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	return NUMBER_OF_LOGIN_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    
    TextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        cell.textField.delegate = self;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }

	cell.textLabel.text = kLoginLabelsArray[indexPath.row];
    cell.textField.text = [self valueForRowAtIndexPath:indexPath];
    cell.textField.tag = indexPath.row;
    
	return cell;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self updateModelFromField:textField];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.currentTextField = nil;
    return YES;
}

#pragma mark - Actions
- (void)navigateToSettings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)joinConference:(id)sender
{
    [self.currentTextField resignFirstResponder];
    [self performSelector:@selector(joinConference) withObject:nil afterDelay:0];
}

- (void)joinConference
{
    [self showActivityIndicator];
    self.participantsController = [[ParticipantsController alloc] init];
    self.logsController = [[LogsController alloc] init];
    self.logsController.participantsController = self.participantsController;
    
    [[ooVooController sharedController] joinConference:self.conferenceId
                                      applicationToken:self.applicationToken
                                         applicationId:self.applicationId
                                       participantInfo:self.opaqueString];
}

#pragma mark - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ConferenceViewController *conferenceVC = [[ConferenceViewController alloc] initWithCollectionViewLayout:[ConferenceLayout new]];
        conferenceVC.logsController = self.logsController;
        conferenceVC.participantsController = self.participantsController;
        conferenceVC.conferenceId = self.conferenceId;
        
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:conferenceVC]
                           animated:YES
                         completion:^{ [self hideActivityIndicator]; }];
        
    });
}


- (void)conferenceDidEnd:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.participantsController = nil;
        self.logsController = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    });
}

- (void)conferenceDidFail:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *reason = [notification.userInfo objectForKey:OOVOOConferenceFailureReasonKey];
        [self hideActivityIndicator];
        [self displayAlertMessage:reason];

        self.logsController = nil;
        self.participantsController = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];

    });
}

#pragma mark - MVC
- (NSString *)valueForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = nil;

    switch (indexPath.row)
    {
        case AppIdRow:
            value = self.applicationId;
            break;
            
        case AppTokenRow:
            value = self.applicationToken;
            break;

        case ConferenceIdRow:
            value = self.conferenceId;
            break;

        case DisplayNameRow:
            value = self.opaqueString;
            break;

        default:
            break;
    }
    
    return value;
}

- (void)updateModelFromField:(UITextField *)textField
{
    NSString *value = textField.text;
    NSUInteger row = textField.tag;
    switch (row)
    {
        case AppIdRow:
            self.applicationId = value;
            break;
            
        case AppTokenRow:
            self.applicationToken = value;
            break;
            
        case ConferenceIdRow:
            self.conferenceId = value;
            break;
            
        case DisplayNameRow:
            self.opaqueString = value;
            break;
            
        default:
            break;
    }
}

#pragma mark - Activity indicator
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator)
    {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    _activityIndicator.frame = self.joinButton.frame;
    
    return _activityIndicator;
}

- (void)showActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{

        self.joinButton.hidden = YES;
        [self.activityIndicator startAnimating];
        
    });
}

- (void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    self.joinButton.hidden = NO;
}

#pragma mark - Alerts
- (void)displayAlertMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:self.title
                                message:[NSString stringWithFormat:@"Error - %@", message]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - Join button
- (UIButton *)joinButton
{
    if (!_joinButton)
    {
        BOOL iPad =  ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        CGFloat margin = iPad? 44.0f : 9.0f;
        self.joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.joinButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.joinButton addTarget:self action:@selector(joinConference:) forControlEvents:UIControlEventTouchUpInside];
        self.joinButton.frame = CGRectMake(margin, margin, CGRectGetWidth(self.tableView.frame) - margin * 2, (iPad? 56.0f : 44.0f));
    }
    
    return _joinButton;
}

@end
