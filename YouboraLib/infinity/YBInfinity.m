//
//  YBInfinity.m
//  YouboraLib
//
//  Created by Enrique Alfonso Burillo on 19/07/2018.
//  Copyright © 2018 NPAW. All rights reserved.
//

#import "YBInfinity.h"

#import "YBInfinityLocalManager.h"
#import "YBInfinityFlags.h"
#import "YBLog.h"
#import "YBCommunication.h"
#import "YBTimestampLastSentTransform.h"
#import "YouboraLib/YouboraLib-Swift.h"

@interface YBInfinity()

@property (nonatomic, strong) YBInfinityLocalManager* infinityStorage;

@end

@implementation YBInfinity

- (id)init {
    if (self = [super init]) {
        self.flags = [[YBInfinityFlags alloc] init];
        self.infinityStorage = [[YBInfinityLocalManager alloc] init];
    }
    return self;
}

- (void) beginWithScreenName: (NSString *) screenName {
    [self beginWithScreenName:screenName andDimensions:nil];
}

- (void) beginWithScreenName: (NSString *) screenName andDimensions:(NSDictionary<NSString *, NSString *> *) dimensions {
    if (dimensions == nil) {
        dimensions = @{};
    }
    
    if (!self.flags.started) {
        self.flags.started = true;
        if (self.viewTransform != nil) {
            [self fireSessionStartWithScreenName:screenName andDimensions:dimensions];
        }
    } else {
        [self fireNavWithScreenName:screenName];
    }
}

- (void) fireSessionStartWithScreenName: (NSString *) screenName andDimensions:(NSDictionary<NSString *, NSString *> *) dimensions{
    [self generateNewContext];
    
    [self.delegate youboraInfinityEventSessionStartWithScreenName:screenName andDimensions:dimensions];
}

- (void) fireNavWithScreenName: (NSString *) screenName {
    [self.delegate youboraInfinityEventNavWithScreenName:screenName];
}

- (void) fireEvent: (NSDictionary<NSString *, NSString *> *) dimensions values: (NSDictionary<NSString *, NSNumber *> *) values andEventName: (NSString *) eventName {
    [self fireEvent:eventName dimensions:dimensions values:values];
}

- (void) fireEvent: (NSString *) eventName dimensions: (NSDictionary<NSString *, NSString *> *) dimensions values: (NSDictionary<NSString *, NSNumber *> *) values {
    if (dimensions == nil) {
        dimensions = @{};
    }
    
    if (values == nil) {
        values = @{};
    }
    
    if (eventName == nil || eventName.length == 0) {
        eventName = @"Unknown";
    }
    
    if (self.delegate) {
        [self.delegate youboraInfinityEventEventWithDimensions:dimensions values:values andEventName:eventName];
    }
}

- (void) fireSessionStop: (NSDictionary<NSString *, NSString *> *) params {
    [self.flags reset];
    if (self.delegate) {
        [self.delegate youboraInfinityEventSessionStop:params];
    }
}

- (void) end {
    [self end:nil];
}

- (void) end:(nullable NSDictionary<NSString *, NSString *> *) params {
    if (self.flags.started) {
        [self fireSessionStop:params];
    }
}

- (void) generateNewContext {
    [self.infinityStorage saveContextWithContext:[YBYouboraUtils getAppName]];
    self.navContext = [YBYouboraUtils getAppName];
}

- (NSNumber *) getLastSent {
    return [self.infinityStorage getLastActive];
}

-(NSString* _Nonnull) getSessionRoot {
    return [self.viewTransform getSessionRoot];
}

@end
