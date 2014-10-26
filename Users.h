//
//  Users.h
//  Vote
//
//  Created by 丁 一 on 14-8-25.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FailedDeletedFriends, FailedDeletedVotes, FailedMsg, Friends, VotesInfo;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSNumber * basicInfoLastUpdateTag;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * headImageLastUpdateTag;
@property (nonatomic, retain) NSString * mediumHeadImagePath;
@property (nonatomic, retain) NSString * mediumHeadImageUrl;
@property (nonatomic, retain) NSString * originalHeadImagePath;
@property (nonatomic, retain) NSString * originalHeadImageUrl;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * screennamePinyin;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * thumbnailsHeadImagePath;
@property (nonatomic, retain) NSString * thumbnailsHeadImageUrl;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * largeHeadImagePath;
@property (nonatomic, retain) NSString * largeHeadImageUrl;
@property (nonatomic, retain) NSSet *deletedFriends;
@property (nonatomic, retain) NSSet *deletedVotes;
@property (nonatomic, retain) NSSet *failedMsg;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *votesInfo;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addDeletedFriendsObject:(FailedDeletedFriends *)value;
- (void)removeDeletedFriendsObject:(FailedDeletedFriends *)value;
- (void)addDeletedFriends:(NSSet *)values;
- (void)removeDeletedFriends:(NSSet *)values;

- (void)addDeletedVotesObject:(FailedDeletedVotes *)value;
- (void)removeDeletedVotesObject:(FailedDeletedVotes *)value;
- (void)addDeletedVotes:(NSSet *)values;
- (void)removeDeletedVotes:(NSSet *)values;

- (void)addFailedMsgObject:(FailedMsg *)value;
- (void)removeFailedMsgObject:(FailedMsg *)value;
- (void)addFailedMsg:(NSSet *)values;
- (void)removeFailedMsg:(NSSet *)values;

- (void)addFriendsObject:(Friends *)value;
- (void)removeFriendsObject:(Friends *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addVotesInfoObject:(VotesInfo *)value;
- (void)removeVotesInfoObject:(VotesInfo *)value;
- (void)addVotesInfo:(NSSet *)values;
- (void)removeVotesInfo:(NSSet *)values;

@end
