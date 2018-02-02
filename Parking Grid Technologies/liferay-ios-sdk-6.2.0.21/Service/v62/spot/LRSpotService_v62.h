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
@interface LRSpotService_v62 : LRBaseService

- (NSDictionary *)getSpotByIdWithSpotId:(long long)spotId error:(NSError **)error;
- (NSString *)getSpotStatusByIdWithSpotId:(long long)spotId error:(NSError **)error;
- (void)updateNodeIdWithSpotId:(long long)spotId nodeId:(long long)nodeId error:(NSError **)error;
- (void)updateSpotCoordinatesWithSpotId:(long long)spotId topLeftX:(int)topLeftX topLeftY:(int)topLeftY topRightX:(int)topRightX topRightY:(int)topRightY bottomLeftX:(int)bottomLeftX bottomLeftY:(int)bottomLeftY bottomRightX:(int)bottomRightX bottomRightY:(int)bottomRightY error:(NSError **)error;

@end