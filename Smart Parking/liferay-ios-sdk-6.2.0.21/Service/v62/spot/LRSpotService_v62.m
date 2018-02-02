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

#import "LRSpotService_v62.h"

/**
 * @author Bruno Farache
 */
@implementation LRSpotService_v62

- (NSDictionary *)getSpotByIdWithSpotId:(long long)spotId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"spotId": @(spotId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.spot/get-spot-by-id": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (NSString *)getSpotStatusByIdWithSpotId:(long long)spotId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"spotId": @(spotId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.spot/get-spot-status-by-id": _params};

	return (NSString *)[self.session invoke:_command error:error];
}

- (void)updateNodeIdWithSpotId:(long long)spotId nodeId:(long long)nodeId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"spotId": @(spotId),
		@"nodeId": @(nodeId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.spot/update-node-id": _params};

	[self.session invoke:_command error:error];
}

- (void)updateSpotCoordinatesWithSpotId:(long long)spotId topLeftX:(int)topLeftX topLeftY:(int)topLeftY topRightX:(int)topRightX topRightY:(int)topRightY bottomLeftX:(int)bottomLeftX bottomLeftY:(int)bottomLeftY bottomRightX:(int)bottomRightX bottomRightY:(int)bottomRightY error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"spotId": @(spotId),
		@"topLeftX": @(topLeftX),
		@"topLeftY": @(topLeftY),
		@"topRightX": @(topRightX),
		@"topRightY": @(topRightY),
		@"bottomLeftX": @(bottomLeftX),
		@"bottomLeftY": @(bottomLeftY),
		@"bottomRightX": @(bottomRightX),
		@"bottomRightY": @(bottomRightY)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.spot/update-spot-coordinates": _params};

	[self.session invoke:_command error:error];
}

@end