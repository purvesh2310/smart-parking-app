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

#import "LRFacilityService_v62.h"

/**
 * @author Bruno Farache
 */
@implementation LRFacilityService_v62

- (NSDictionary *)getFacilityWithFacilityId:(long long)facilityId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"facilityId": @(facilityId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.facility/get-facility": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (NSArray *)getFacilitySpotsWithFacilityId:(long long)facilityId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"facilityId": @(facilityId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.facility/get-facility-spots": _params};

	return (NSArray *)[self.session invoke:_command error:error];
}

- (NSArray *)getFacilityZonesWithFacilityId:(long long)facilityId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"facilityId": @(facilityId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.facility/get-facility-zones": _params};

	return (NSArray *)[self.session invoke:_command error:error];
}

- (NSArray *)getNearestFacilitiesWithLatitude:(double)latitude longitude:(double)longitude limit:(int)limit error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"latitude": @(latitude),
		@"longitude": @(longitude),
		@"limit": @(limit)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.facility/get-nearest-facilities": _params};

	return (NSArray *)[self.session invoke:_command error:error];
}

@end