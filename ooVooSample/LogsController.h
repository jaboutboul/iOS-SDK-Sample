//
// LogsController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "UITextViewLogger.h"
#import "ParticipantsController.h"

@interface LogsController : NSObject

@property (nonatomic, strong) UITextViewLogger *textViewLogger;
@property (nonatomic, strong) ParticipantsController *participantsController;

@end
