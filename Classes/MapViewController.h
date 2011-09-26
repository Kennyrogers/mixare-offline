/* Copyright (C) 2010- Peer internet solutions
 * 
 * This file is part of mixare.
 * 
 * This program is free software: you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by 
 * the Free Software Foundation, either version 3 of the License, or 
 * (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details. 
 * 
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see <http://www.gnu.org/licenses/> */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TileOverlay.h"

@interface MapAnnotation : NSObject<MKAnnotation> {
    CGFloat _lat;
	CGFloat _lon;
	CGFloat _altitude;
	NSString * _title;
	NSString * _subTitle;
    NSString * _source;
}
@property (nonatomic) CGFloat lat; 
@property (nonatomic) CGFloat lon;
@property (nonatomic) CGFloat altitude; 
@property (nonatomic,retain) NSString * title;
@property (nonatomic,retain) NSString * subTitle;
@property (nonatomic,retain) NSString *source;



@end

@interface MapViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate> {
	IBOutlet MKMapView* _map;
	MKCoordinateRegion _focusArea;
	NSMutableArray *_data;
	
	CLLocationCoordinate2D _longPressedCoords;
}

@property (nonatomic) CLLocationCoordinate2D longPressedCoords;
@property(nonatomic,retain)MKMapView *map;
@property (nonatomic) MKCoordinateRegion focusArea;
@property (nonatomic, retain) NSMutableArray * data;
@property (nonatomic, retain) TileOverlay *overlay;

-(void) mapDataToMapAnnotations;
- (void) AnnotationInfoButtonClick:(id)sender;
- (void) AnnotationDeleteButtonClick:(id)sender;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)ovl;
@end
