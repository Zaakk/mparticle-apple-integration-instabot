//
//  MPKitInstabot.m
//
//  Copyright 2017 ROKO Labs, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitInstabot.h"

@implementation MPKitInstabot

+ (NSNumber *)kitCode {
    return @123;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Instabot" className:@"MPKitInstabot"];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (nonnull instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    NSString *appKey = configuration[@"apiKey"];
    if (!self || !appKey) {
        return nil;
    }
    
    [[Instabot shared] setAPIKey:appKey];
    
    _configuration = configuration;

    if (startImmediately) {
        [self start];
    }
    
    return self;
}

- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        _started = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    return [self started] ? [Instabot shared] : nil;
}

#pragma mark Push

- (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark User attributes and identities

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    Instabot *instabot = [Instabot shared];
    
    [[instabot account] setUserCustomProperty:value forKey:key completionBlock:^(NSError * _Nullable error) {
        if (error) NSLog(@"%@", error);
    }];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    Instabot *instabot = [Instabot shared];
    
    if (identityType == MPUserIdentityCustomerId || identityType == MPUserIdentityEmail) {
        [[instabot account] setUserWithName:identityString completionBlock:^(NSError * _Nullable error) {}];
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    } else {
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeCannotExecute];
    }
}

- (MPKitExecStatus *)logout {
    Instabot *instabot = [Instabot shared];
    [[instabot account] logoutWithCompletionBlock:^(NSError * _Nullable error) {
        if (error) NSLog(@"%@", error);
    }];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#pragma mark Events

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    if (event.info) {
        [IBAnalytics addEvent:event.name withParameters:event.info];
    } else {
        [IBAnalytics addEvent:event.name];
    }
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)didFinishLaunchingWithConfiguration:(nonnull NSDictionary *)configuration {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceInstabot) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}


@end
