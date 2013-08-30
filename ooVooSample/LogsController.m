//
// LogsController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "LogsController.h"
#import "ooVooController.h"
#import "DDLog.h"

@interface LogsController ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation LogsController

- (id)init
{
    if ((self = [super init]))
    {
        self.textViewLogger = [[UITextViewLogger alloc] init];
        self.textViewLogger.autoScrollsToBottom = YES;
        [DDLog addLogger:self.textViewLogger];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(conferenceDidBegin:) name:OOVOOConferenceDidBeginNotification object:nil];
        [nc addObserver:self selector:@selector(conferenceDidFail:) name:OOVOOConferenceDidFailNotification object:nil];
        [nc addObserver:self selector:@selector(conferenceDidEnd:) name:OOVOOConferenceDidEndNotification object:nil];
        
        [nc addObserver:self selector:@selector(participantDidJoin:) name:OOVOOParticipantDidJoinNotification object:nil];
        [nc addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];
        [nc addObserver:self selector:@selector(participantDidChange:) name:OOVOOParticipantVideoStateDidChangeNotification object:nil];
        
        [nc addObserver:self selector:@selector(videoDidStop:) name:OOVOOVideoDidStopNotification object:nil];
        [nc addObserver:self selector:@selector(videoDidStart:) name:OOVOOVideoDidStartNotification object:nil];
        
        [nc addObserver:self selector:@selector(userDidMuteMicrophone:) name:OOVOOUserDidMuteMicrophoneNotification object:nil];
        [nc addObserver:self selector:@selector(userDidUnmuteMicrophone:) name:OOVOOUserDidUnmuteMicrophoneNotification object:nil];
        [nc addObserver:self selector:@selector(userDidMuteSpeaker:) name:OOVOOUserDidMuteSpeakerNotification object:nil];
        [nc addObserver:self selector:@selector(userDidUnmuteSpeaker:) name:OOVOOUserDidUnmuteSpeakerNotification object:nil];
        
        [nc addObserver:self selector:@selector(connectionStatisticsDidUpdate:) name:OOVOOConnectionStatisticsNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    
    return _dateFormatter;
}

- (NSString *)timestamp
{
    return [self.dateFormatter stringFromDate:[NSDate date]];
}

#pragma - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    DDLogInfo(@"%@ Joined the conference.", [self timestamp]);
}

- (void)conferenceDidEnd:(NSNotification *)notification
{
    DDLogInfo(@"%@ Left the conference.", [self timestamp]);
}

- (void)conferenceDidFail:(NSNotification *)notification
{
    NSString *reason = [notification.userInfo objectForKey:OOVOOConferenceFailureReasonKey];
    DDLogInfo(@"%@ Conference failed: %@", [self timestamp], reason);
}


- (void)participantDidJoin:(NSNotification *)notification
{
    NSString *displayName = notification.userInfo[OOVOOParticipantInfoKey];
    DDLogInfo(@"%@ %@ joined the conference.", [self timestamp], displayName);
}

- (void)participantDidLeave:(NSNotification *)notification
{
    NSString *participantId = notification.userInfo[OOVOOParticipantIdKey];
    NSString *displayName = [self.participantsController participantWithId:participantId].displayName;
    DDLogInfo(@"%@ %@ left the conference.", [self timestamp], displayName);
}

- (void)participantDidChange:(NSNotification *)notification
{
    NSString *participantId = notification.userInfo[OOVOOParticipantIdKey];
    NSString *displayName = [self.participantsController participantWithId:participantId].displayName;

    ooVooVideoState state = (ooVooVideoState)[notification.userInfo[OOVOOParticipantStateKey] integerValue];
    
    NSString *stateDescription = nil;
    
    switch (state) {
        case ooVooVideoOn:
            stateDescription = @"On";
            break;
            
        case ooVooVideoOff:
            stateDescription = @"Off";
            break;
            
        case ooVooVideoPaused:
            stateDescription = @"Paused";
            break;
            
        default:
            break;
    }
    
    DDLogInfo(@"%@ %@ changed video state to: %@", [self timestamp], displayName, stateDescription);
}


- (void)videoDidStop:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    DDLogInfo(@"%@ My video turned off (error: %d)", [self timestamp], [errorNumber integerValue]);
}

- (void)videoDidStart:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    NSNumber *width = notification.userInfo[OOVOOVideoWidth];
    NSNumber *height = notification.userInfo[OOVOOVideoHeight];
    
    DDLogInfo(@"%@ My video turned on (error: %d). Video size: %dx%d", [self timestamp], [errorNumber integerValue], [width integerValue], [height integerValue]);
}


- (void)userDidMuteMicrophone:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    DDLogInfo(@"%@ Microphone turned off (error: %d)", [self timestamp], [errorNumber integerValue]);
}

- (void)userDidUnmuteMicrophone:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    DDLogInfo(@"%@ Microphone turned on (error: %d)", [self timestamp], [errorNumber integerValue]);
}

- (void)userDidMuteSpeaker:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    DDLogInfo(@"%@ Speaker turned off (error: %d)", [self timestamp], [errorNumber integerValue]);
}

- (void)userDidUnmuteSpeaker:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    DDLogInfo(@"%@ Speaker turned on (error: %d)", [self timestamp], [errorNumber integerValue]);
}


- (void)connectionStatisticsDidUpdate:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    uint32_t inboundPacketLoss, outboundPacketLoss;
    uint32_t inboundBandwidth, outboundBandwidth;
    
    inboundBandwidth = [info[OOVOOStatisticsInboundBandwidthKey] integerValue];
    inboundPacketLoss = [info[OOVOOStatisticsInboundPacketLossKey] doubleValue];
    outboundBandwidth = [info[OOVOOStatisticsOutboundBandwidthKey] integerValue];
    outboundPacketLoss = [info[OOVOOStatisticsOutboundPacketLossKey] doubleValue];
    
    DDLogInfo(@"%@ Connection statistics updated. Inbound packet loss:%d, Outbound packet loss:%d, Inbound bandwidth:%d",
              [self timestamp], inboundPacketLoss, outboundPacketLoss, inboundBandwidth);
}

@end
