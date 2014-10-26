//
//  VotesInfo.h
//  Vote
//
//  Created by 丁 一 on 14-10-1.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Options, Users, VotesUserSetting;

@interface VotesInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * anonymous;
@property (nonatomic, retain) NSNumber * basicUpdateFlag;
@property (nonatomic, retain) NSNumber * basicUpdateTag;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * draft;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isEnd;
@property (nonatomic, retain) NSNumber * maxChoice;
@property (nonatomic, retain) NSString * organizer;
@property (nonatomic, retain) NSString * organizerSceenName;
@property (nonatomic, copy) NSMutableArray * participants;
@property (nonatomic, copy) NSMutableArray * preChoose;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * thePublic;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * voteDescription;
@property (nonatomic, retain) NSNumber * voteID;
@property (nonatomic, retain) NSNumber * voteUpdateFlag;
@property (nonatomic, retain) NSNumber * voteUpdateTag;
@property (nonatomic, copy) NSMutableArray * confirmers;
@property (nonatomic, retain) NSSet *options;
@property (nonatomic, retain) NSSet *userSetting;
@property (nonatomic, retain) Users *whoseVote;
@end

@interface VotesInfo (CoreDataGeneratedAccessors)

- (void)addOptionsObject:(Options *)value;
- (void)removeOptionsObject:(Options *)value;
- (void)addOptions:(NSSet *)values;
- (void)removeOptions:(NSSet *)values;

- (void)addUserSettingObject:(VotesUserSetting *)value;
- (void)removeUserSettingObject:(VotesUserSetting *)value;
- (void)addUserSetting:(NSSet *)values;
- (void)removeUserSetting:(NSSet *)values;

@end
