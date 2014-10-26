//
//  VoteLookUpParticipantsFlowLayout.m
//  Vote
//
//  Created by 丁 一 on 14-8-13.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteLookUpParticipantsFlowLayout.h"

@implementation VoteLookUpParticipantsFlowLayout

- (id)init
{
    if (self = [super init])
    {
        self.itemSize = CGSizeMake(60, 75);
        self.minimumInteritemSpacing = 15;
        self.minimumLineSpacing = 16;
        //self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(20, 16, 20, 16);
    }
    return self;
}


@end
