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

+ (CLLocation*) getUserProvidedLocation;
+ (void) setUserProvidedLocation:(CLLocation*)loc;
+ (BOOL) isCustomUserLocSet;
+ (void)saveImage:(UIImage*)img:(NSString*)imgName;
+ (UIImage*)loadImage:(NSString*)imageName;
+ (void)deleteImage:(NSString*)imageName;
+(NSMutableDictionary *)updateMetadata:(NSMutableDictionary *)metadataAsMutable:(NSString *)userComment;
+(NSMutableDictionary *)updateEXIFDicationary:(NSMutableDictionary *)exifDict:(NSString *)userComment;
+(NSMutableDictionary *)updateGPSDictionary:(NSMutableDictionary *)gpsDict;
+(double)calculateDistanceFromUser:(CLLocation *)itemLoc;

@end
