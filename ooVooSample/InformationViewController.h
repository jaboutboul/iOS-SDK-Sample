//
// InformationViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//


#import "ParticipantsController.h"

@interface InformationViewController : UITableViewController

@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, copy) NSString *conferenceId;

@end
