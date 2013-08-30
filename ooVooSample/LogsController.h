//
// LogsController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "UITextViewLogger.h"
#import "ParticipantsController.h"

@interface LogsController : NSObject

@property (nonatomic, strong) UITextViewLogger *textViewLogger;
@property (nonatomic, strong) ParticipantsController *participantsController;

@end
