//
//  MixareUtils.h
//  Mixare
//
//  Created by David Ho on 9/22/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MixareUtils : NSObject {

}

+ (CLLocationCoordinate2D) GetUserPosition;
+ (void) setUserProvidedLocation:(CLLocationCoordinate2D)loc;
+ (BOOL) isCustomUserLocSet;

@end
