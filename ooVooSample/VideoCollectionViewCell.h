//
// VideoCollectionViewCell.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  License under Apache 2.0 license. http://www.apache.org/licenses/LICENSE-2.0.html 
//

#import "ooVooVideoView.h"

@interface VideoCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) ooVooVideoView *videoView;
@property(nonatomic, strong) UIImageView *avatarImgView;
@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UILabel *stateLabel;

- (void)hideAvatar;
- (void)showAvatar;
- (BOOL)isAvatarHidden;

- (void)showState:(NSString*)text;
- (void)hideState;

@end
