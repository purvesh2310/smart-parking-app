/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

#import "LRBaseService.h"

/**
 * @author Bruno Farache
 */
@interface LRDriverService_v62 : LRBaseService

- (NSDictionary *)createDriverAccountWithFirstName:(NSString *)firstName lastName:(NSString *)lastName userOrgName:(NSString *)userOrgName emailAddress:(NSString *)emailAddress password:(NSString *)password captchaText:(NSString *)captchaText error:(NSError **)error;
- (NSDictionary *)getDriverByUserIdWithUserId:(long long)userId error:(NSError **)error;
- (NSString *)getUserPortraitUrlWithUserId:(long long)userId error:(NSError **)error;
- (NSDictionary *)signinWithSocialPlatformWithFirstName:(NSString *)firstName lastName:(NSString *)lastName emailAddress:(NSString *)emailAddress portraitURL:(NSString *)portraitURL accessToken:(NSString *)accessToken loginType:(NSString *)loginType error:(NSError **)error;
- (NSDictionary *)updateDriverAccountWithFirstName:(NSString *)firstName lastName:(NSString *)lastName userOrgName:(NSString *)userOrgName emailAddress:(NSString *)emailAddress password:(NSString *)password error:(NSError **)error;
- (void)updateUserPhoneNumberWithUserId:(long long)userId phoneNumber:(NSString *)phoneNumber error:(NSError **)error;

@end