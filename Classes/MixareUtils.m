//
//  MixareUtils.m
//  Mixare
//
//  Created by David Ho on 9/22/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import "MixareUtils.h"
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MixareUtils

static CLLocation *userProvidedLocation = nil;

+ (CLLocation*) getUserProvidedLocation
{
	if ([self isCustomUserLocSet]){
		return userProvidedLocation;
	}
	else {
		CLLocationManager *locmng = [[CLLocationManager alloc]init];
		CLLocation *location = locmng.location;
		[locmng release];
		return location;
	}
}

+ (void) setUserProvidedLocation:(CLLocation*)loc
{
	[userProvidedLocation release];
	userProvidedLocation = loc;
	[userProvidedLocation retain];
}

+ (BOOL) isCustomUserLocSet
{
	if (userProvidedLocation == nil) {
		return false;
	}
	return true;
}


//saving an image

+ (void)saveImage:(UIImage*)img:(NSString*)imgName {
    
    NSData *imageData = UIImageJPEGRepresentation(img,1.0); //convert image into .jpeg format.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", imgName]]; //add our image to the path
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    
    NSLog(@"image saved");
    
}

// loading an image
+ (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", imageName]];
    UIImage *loadedImage = [UIImage imageWithContentsOfFile:fullPath];
    if(!loadedImage)
        loadedImage = [UIImage imageNamed:@"404.jpg"];
    
    return loadedImage;
    
}

+ (void)deleteImage:(NSString*)imageName {
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", imageName]]; //add our image to the path
    
    [fileManager removeItemAtPath:fullPath error:NULL]; //finally delete the path (image)
    
    NSLog(@"image deleted");
}

+(NSMutableDictionary *)updateMetadata:(NSMutableDictionary *)metadataAsMutable:(NSString *)userComment{
    if(!metadataAsMutable)
        metadataAsMutable = [NSMutableDictionary dictionary];
    
    [metadataAsMutable setObject:[self updateGPSDictionary:[[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy]autorelease]] forKey:(NSString *)kCGImagePropertyGPSDictionary];
    [metadataAsMutable setObject:[self updateEXIFDicationary:[[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy]autorelease]:userComment] forKey:(NSString *)kCGImagePropertyExifDictionary];
    
    
    return metadataAsMutable;
}



+(NSMutableDictionary *)updateEXIFDicationary:(NSMutableDictionary *)exifDict:(NSString *)userComment{
    if(!exifDict)
        exifDict = [NSMutableDictionary dictionary];
   
    [exifDict setObject:userComment forKey:(NSString*)kCGImagePropertyExifUserComment];
    
    return exifDict;
}

+ (NSMutableDictionary *)updateGPSDictionary:(NSMutableDictionary *)gpsDict{
    if(!gpsDict)
        gpsDict = [NSMutableDictionary dictionary];
    
    // POI's location
    //    CLLocation *location = [[CLLocation alloc] initWithLatitude:[textFieldLat.text floatValue] longitude:[textFieldLon.text floatValue]];
    
    //current location
	CLLocation *location = [self getUserProvidedLocation];
    
    if (location) {
        gpsDict = [[NSMutableDictionary alloc] init];
        CLLocationDegrees exifLatitude  = location.coordinate.latitude;
        CLLocationDegrees exifLongitude = location.coordinate.longitude;
        
        NSString *latRef;
        NSString *lngRef;
        if (exifLatitude < 0.0) {
            exifLatitude = exifLatitude * -1.0f;
            latRef = @"S";
        } else {
            latRef = @"N";
        }
        
        if (exifLongitude < 0.0) {
            exifLongitude = exifLongitude * -1.0f;
            lngRef = @"W";
        } else {
            lngRef = @"E";
        } 
        
        [gpsDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        [gpsDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        [gpsDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        [gpsDict setObject:lngRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        [gpsDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
        [gpsDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
        [gpsDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    }
    return [gpsDict autorelease]; 
}


+ (double)calculateDistanceFromUser:(CLLocation *)itemLoc{
    double distance = -1;
    if(itemLoc)
        distance = [itemLoc distanceFromLocation:[self getUserProvidedLocation]];
    return distance;
}
@end
