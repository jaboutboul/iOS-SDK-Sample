//
// ConferenceViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "ParticipantsController.h"
#import "LogsController.h"

@interface ConferenceViewController : UICollectionViewController <ParticipantsControllerDelegate>

@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;
@property (nonatomic, copy) NSString *conferenceId;

@end
