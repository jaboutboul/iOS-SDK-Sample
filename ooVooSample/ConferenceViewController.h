//
// ConferenceViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ParticipantsController.h"
#import "LogsController.h"

@interface ConferenceViewController : UICollectionViewController <ParticipantsControllerDelegate>

@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;
@property (nonatomic, copy) NSString *conferenceId;

@end
