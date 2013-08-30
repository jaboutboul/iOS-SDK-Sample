//
// ConferenceLayout.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ConferenceLayout.h"

@implementation ConferenceLayout

- (id)init
{
    if (self = [super init])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.itemSize = CGSizeMake(200, 200);
            self.minimumInteritemSpacing = 10;
            self.minimumLineSpacing = 20;
            self.sectionInset = UIEdgeInsetsMake(20, 40, 20, 40);
        }
        else
        {
            self.itemSize = CGSizeMake(150, 150);
            self.minimumInteritemSpacing = 10;
            self.minimumLineSpacing = 10;
            self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        }
        
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    return self;
}

@end
