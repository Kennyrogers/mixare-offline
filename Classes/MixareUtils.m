//
//  MixareUtils.m
//  Mixare
//
//  Created by David Ho on 9/22/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import "MixareUtils.h"


@implementation MixareUtils

static CLLocationCoordinate2D userProvidedLocation;

+ (CLLocationCoordinate2D) GetUserPosition
{
	CLLocationCoordinate2D coords;
	
	if (userProvidedLocation.latitude == 0 && userProvidedLocation.longitude == 0) {
		CLLocationManager* locmng = [[CLLocationManager alloc]init];
		coords = CLLocationCoordinate2DMake(locmng.location.coordinate.latitude, locmng.location.coordinate.longitude);
		[locmng release];
	}
	else {
		coords = CLLocationCoordinate2DMake(userProvidedLocation.latitude, userProvidedLocation.longitude);
	}
	
	return coords;
}

+ (void) setUserProvidedLocation:(CLLocationCoordinate2D)loc
{
	userProvidedLocation = loc;
}

+ (BOOL) isCustomUserLocSet
{
	if (userProvidedLocation.latitude == 0 && userProvidedLocation.longitude == 0) {
		return false;
	}
	return true;
}

@end
