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

#import "LRDriverService_v62.h"

/**
 * @author Bruno Farache
 */
@implementation LRDriverService_v62

- (NSDictionary *)createDriverAccountWithFirstName:(NSString *)firstName lastName:(NSString *)lastName userOrgName:(NSString *)userOrgName emailAddress:(NSString *)emailAddress password:(NSString *)password captchaText:(NSString *)captchaText error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"firstName": [self checkNull: firstName],
		@"lastName": [self checkNull: lastName],
		@"userOrgName": [self checkNull: userOrgName],
		@"emailAddress": [self checkNull: emailAddress],
		@"password": [self checkNull: password],
		@"captchaText": [self checkNull: captchaText]
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.driver/create-driver-account": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (NSDictionary *)getDriverByUserIdWithUserId:(long long)userId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"userId": @(userId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.driver/get-driver-by-user-id": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (NSString *)getUserPortraitUrlWithUserId:(long long)userId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"userId": @(userId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.driver/get-user-portrait-url": _params};

	return (NSString *)[self.session invoke:_command error:error];
}

- (NSDictionary *)signinWithSocialPlatformWithFirstName:(NSString *)firstName lastName:(NSString *)lastName emailAddress:(NSString *)emailAddress portraitURL:(NSString *)portraitURL accessToken:(NSString *)accessToken loginType:(NSString *)loginType error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"firstName": [self checkNull: firstName],
		@"lastName": [self checkNull: lastName],
		@"emailAddress": [self checkNull: emailAddress],
		@"portraitURL": [self checkNull: portraitURL],
		@"accessToken": [self checkNull: accessToken],
		@"loginType": [self checkNull: loginType]
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.driver/signin-with-social-platform": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (NSDictionary *)updateDriverAccountWithFirstName:(NSString *)firstName lastName:(NSString *)lastName userOrgName:(NSString *)userOrgName emailAddress:(NSString *)emailAddress password:(NSString *)password error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"firstName": [self checkNull: firstName],
		@"lastName": [self checkNull: lastName],
		@"userOrgName": [self checkNull: userOrgName],
		@"emailAddress": [self checkNull: emailAddress],
		@"password": [self checkNull: password]
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.driver/update-driver-account": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (void)updateUserPhoneNumberWithUserId:(long long)userId phoneNumber:(NSString *)phoneNumber error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"userId": @(userId),
		@"phoneNumber": [self checkNull: phoneNumber]
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.driver/update-user-phone-number": _params};

	[self.session invoke:_command error:error];
}

@end