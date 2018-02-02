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

#import "LRGatewayService_v62.h"

/**
 * @author Bruno Farache
 */
@implementation LRGatewayService_v62

- (NSDictionary *)initializeGatewayWithGatewayCode:(NSString *)gatewayCode gatewayName:(NSString *)gatewayName description:(NSString *)description gatewayStatusId:(long long)gatewayStatusId nodeCount:(int)nodeCount error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"gatewayCode": [self checkNull: gatewayCode],
		@"gatewayName": [self checkNull: gatewayName],
		@"description": [self checkNull: description],
		@"gatewayStatusId": @(gatewayStatusId),
		@"nodeCount": @(nodeCount)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.gateway/initialize-gateway": _params};

	return (NSDictionary *)[self.session invoke:_command error:error];
}

- (void)updateGatewayStatusWithGatewayCode:(NSString *)gatewayCode gatewayStatusId:(long long)gatewayStatusId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"gatewayCode": [self checkNull: gatewayCode],
		@"gatewayStatusId": @(gatewayStatusId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.gateway/update-gateway-status": _params};

	[self.session invoke:_command error:error];
}

- (void)updateNodeStateWithGatewayCode:(NSString *)gatewayCode nodeNumber:(int)nodeNumber nodeStatusId:(long long)nodeStatusId error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"gatewayCode": [self checkNull: gatewayCode],
		@"nodeNumber": @(nodeNumber),
		@"nodeStatusId": @(nodeStatusId)
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.gateway/update-node-state": _params};

	[self.session invoke:_command error:error];
}

- (void)updateNodeStatusMapWithGatewayCode:(NSString *)gatewayCode nodeStatusList:(NSArray *)nodeStatusList error:(NSError **)error {
	NSMutableDictionary *_params = [NSMutableDictionary dictionaryWithDictionary:@{
		@"gatewayCode": [self checkNull: gatewayCode],
		@"nodeStatusList": [self checkNull: nodeStatusList]
	}];

	NSDictionary *_command = @{@"/parking-grid-portlet.gateway/update-node-status-map": _params};

	[self.session invoke:_command error:error];
}

@end