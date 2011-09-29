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

#import "MapViewController.h"
#import "AddPOIController.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"
#import "MixareUtils.h"


@implementation MapAnnotation
@synthesize coordinate;
@synthesize lat=_lat,lon=_lon,altitude= _altitude;
@synthesize subtitle= _subTitle, title= _title, source=_source;


- (CLLocationCoordinate2D)coordinate;{
    CLLocationCoordinate2D position;
	if (_lat != 0.0 && _lon != 0.0) {
		position.latitude = _lat;
		position.longitude = _lon;
	}else {
		position.latitude=0.0;
		position.longitude=0.0;
	}
    
    return position; 
}

@end


@implementation MapViewController
@synthesize map  = _map;
@synthesize mapTileToggleButton = _mapTileToggleButton;
@synthesize focusPOIIndex = _focusPOIIndex;
@synthesize data = _data;
@synthesize overlay;
@synthesize longPressedCoords = _longPressedCoords;
@synthesize locmng = _locmng;

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	    [self mapDataToMapAnnotations];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	_focusPOIIndex = -1;
    _map.delegate= self;
	_locmng = [[CLLocationManager alloc]init];
    _locmng.desiredAccuracy = kCLLocationAccuracyBest;
    _locmng.delegate = self;
	MKCoordinateRegion newRegion;
	CLLocationCoordinate2D userLocation = [MixareUtils getUserProvidedLocation].coordinate;
	newRegion.center.latitude = userLocation.latitude;
	newRegion.center.longitude = userLocation.longitude;
	newRegion.span.latitudeDelta = 0.03;
	newRegion.span.longitudeDelta = 0.03;

	[self mapDataToMapAnnotations];
	
	self.navigationItem.title = NSLocalizedString(@"Map", nil);

    overlay = [[TileOverlay alloc] initOverlay];
    [self.map addOverlay:overlay];
    MKMapRect visibleRect = [self.map mapRectThatFits:overlay.boundingMapRect];
    visibleRect.size.width /= 2;
    visibleRect.size.height /= 2;
    visibleRect.origin.x += visibleRect.size.width / 2;
    visibleRect.origin.y += visibleRect.size.height / 2;
    self.map.visibleMapRect = visibleRect;
	
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	[self.map addGestureRecognizer:longPressGesture];
	[longPressGesture release];
	
	[self.map setRegion:newRegion animated:YES];

}

- (void) viewWillAppear:(BOOL)animated
{
	[self mapDataToMapAnnotations];
}

- (void) viewDidAppear:(BOOL)animated
{
	if(_focusPOIIndex != -1) {
        
        NSString* poiName = [[_data objectAtIndex:_focusPOIIndex]valueForKey:@"title"];
        float lat = [[[_data objectAtIndex:_focusPOIIndex]valueForKey:@"lat"] floatValue];
        float lon = [[[_data objectAtIndex:_focusPOIIndex]valueForKey:@"lon"] floatValue];
        
        MKCoordinateRegion focusArea;
        focusArea.center.latitude = lat;
        focusArea.center.longitude = lon;
        focusArea.span.latitudeDelta = 0.03;
        focusArea.span.latitudeDelta = 0.03;
        [self.map setRegion:focusArea animated:YES];
        
        for (id <MKAnnotation> annotation in self.map.annotations)
        {
            if (annotation.title == poiName)
            {
                [self.map selectAnnotation:annotation animated:YES];
            }
        }
	}
	_focusPOIIndex = -1;
}

- (void) viewWillDisappear:(BOOL)animated
{
	[_locmng stopUpdatingLocation];
}


-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
	
	if (sender.state == UIGestureRecognizerStateBegan) {
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:@"Options"];
		[alert setMessage:@"Insert POI here, or manually specify user location ?"];
		[alert setDelegate:self];
		[alert addButtonWithTitle:@"POI"];
		[alert addButtonWithTitle:@"User Location"];
		[alert show];
		[alert release];
		
		CGPoint point = [sender locationInView:self.map];
		_longPressedCoords = [self.map convertPoint:point toCoordinateFromView:self.map];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) //POI
	{
		// Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
		AddPOIController *poiController = [[AddPOIController alloc] initWithNibName:@"AddPOIController" bundle:nil];
		[poiController setInitialLat:[NSString stringWithFormat:@"%8lf", _longPressedCoords.latitude]];
		[poiController setInitialLon:[NSString stringWithFormat:@"%8lf", _longPressedCoords.longitude]];	
		[poiController setDataSourceArray:_data];
		
		if(![[self.navigationController visibleViewController] isKindOfClass:[AddPOIController class]])
		{
			[[self navigationController] pushViewController:poiController animated:YES];
		}
		
		[poiController release];
	}
	else if (buttonIndex == 1) //User Location
	{
        CLLocation* loc = [[CLLocation alloc] initWithLatitude:_longPressedCoords.latitude longitude:_longPressedCoords.longitude];
        [MixareUtils setUserProvidedLocation:loc];
        [loc release];
		[self mapDataToMapAnnotations];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void) mapDataToMapAnnotations
{
	if(_data != nil)
	{
        NSMutableDictionary *existingAnnotations = [[NSMutableDictionary alloc] init];
        
        for (id <MKAnnotation> annotation in self.map.annotations)
		{
			if (annotation != self.map.userLocation)
			{
				[existingAnnotations setObject:annotation forKey:annotation.title];
			}
		}
		
        
        MapAnnotation * tmpPlace;
		
        for(NSDictionary * poi in _data)
        {
			MapAnnotation* existingAnnotation = [existingAnnotations valueForKey:[poi valueForKey:@"title"]];
            
            if (existingAnnotation == nil) //"Nil" indicates that this is a new POI
            {
                tmpPlace = [[MapAnnotation alloc]init];
                [self.map addAnnotation:tmpPlace];
            }
            else 
            {
                tmpPlace = existingAnnotation;
                [existingAnnotations removeObjectForKey:[poi valueForKey:@"title"]];
                [tmpPlace retain];
            }
			
			tmpPlace.title = [poi valueForKey:@"title"];
			tmpPlace.lat = [[poi valueForKey:@"lat"]floatValue];
			tmpPlace.lon = [[poi valueForKey:@"lon"]floatValue];
			
			tmpPlace.source = [poi valueForKey:@"source"];
			
			//Calculating distance from user location
			CLLocation* poiLocation = [[CLLocation alloc] initWithLatitude:tmpPlace.lat longitude:tmpPlace.lon];
			tmpPlace.subtitle = [NSString stringWithFormat:@"Distance: %.2f km", [MixareUtils calculateDistanceFromUser:poiLocation]/1000];
			[poiLocation release];
			
			[tmpPlace release];
		}
		
		for (id key in existingAnnotations) //Any remaining Annotations here are deleted annotations, so we remove them
		{
			[self.map removeAnnotation:[existingAnnotations objectForKey:key]];
		}
		
		if ([MixareUtils isCustomUserLocSet]) 
		{
			tmpPlace = [[MapAnnotation alloc]init];
			tmpPlace.title = @"Custom User Location";
			tmpPlace.lat = [MixareUtils getUserProvidedLocation].coordinate.latitude;
			tmpPlace.lon = [MixareUtils getUserProvidedLocation].coordinate.longitude;
			tmpPlace.subtitle = @"Delete this to revert to GPS usage.";
			tmpPlace.source = @"";
			
			[self.map addAnnotation:tmpPlace];
			[tmpPlace release];
			[_locmng stopUpdatingLocation];
		}
		else 
		{
			[_locmng startUpdatingLocation];
		}
		
		
		[existingAnnotations release];
	}
}

- (IBAction) ToggleMapTiles:(id)sender
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// getting an NSString
	NSString *tilePreference = [prefs stringForKey:@"mapTilesToDisplay"];
	
	if (tilePreference == @"TILES_SAT") {
		[prefs setObject:@"TILES_TOPO" forKey:@"mapTilesToDisplay"];
		[_mapTileToggleButton setTitle:@"Topo Map"];
	}
	else {
		[prefs setObject:@"TILES_SAT" forKey:@"mapTilesToDisplay"];
		[_mapTileToggleButton setTitle:@"Sat Map"];
	}
	
	[self.map removeOverlay:overlay];
	overlay = [[TileOverlay alloc] initOverlay];
    [self.map addOverlay:overlay];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)ovl
{
    TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:ovl];
    view.tileAlpha = 1.0; // e.g. 0.6 alpha for semi-transparent overlay
    return [view autorelease];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	if (annotation == self.map.userLocation) {
		return nil;
	}

    
	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.canShowCallout = YES;    
	annView.animatesDrop = YES;
	annView.calloutOffset = CGPointMake(-5, 5);

	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *image = [UIImage imageNamed:@"button_general_delete.png"];
	deleteButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	[deleteButton addTarget:self action:@selector(AnnotationDeleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[deleteButton setImage:image forState:UIControlStateNormal];
	[deleteButton setTag:[self.map.annotations indexOfObject:annotation]];
	annView.leftCalloutAccessoryView = deleteButton;

	if([annotation title] == @"Custom User Location")
	{
		annView.pinColor = MKPinAnnotationColorGreen;
		return annView;
	}

	UIButton *moreInfoButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure]; 
	[moreInfoButton addTarget:self action:@selector(AnnotationInfoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[moreInfoButton setTag:[self.map.annotations indexOfObject:annotation]];
	annView.rightCalloutAccessoryView = moreInfoButton;

	return annView;
}


- (IBAction) AnnotationInfoButtonClick:(id)sender
{
	NSLog(@"Tag No: %d", ((UIButton*) sender).tag);
	
	id<MKAnnotation> anno = [self.map.annotations objectAtIndex:((UIButton*) sender).tag];
	NSLog(@"Info Annotation Button Clicked: %@", [anno title]);
	
	AddPOIController *poiController = [[AddPOIController alloc] initWithNibName:@"AddPOIController" bundle:nil];

    NSString *title= [anno title];
    NSString *lat= [NSString stringWithFormat:@"%8lf", [anno coordinate].latitude];
    NSString *lon= [NSString stringWithFormat:@"%8lf", [anno coordinate].longitude];
    
    [poiController setInitialName:title];
    [poiController setInitialLat:lat];
    [poiController setInitialLon:lon];

	[poiController setInitialImage:[MixareUtils loadImage:title]];
    
	
    if(![[self.navigationController visibleViewController] isKindOfClass:[AddPOIController class]])
    {
        [[self navigationController] pushViewController:poiController animated:YES];
    }
    
    poiController.capture.hidden = YES;
    poiController.choose.hidden = YES;
    poiController.saveNewPOIButton.hidden = YES;
	
	[poiController release];
}

- (IBAction) AnnotationDeleteButtonClick:(id)sender
{
	id<MKAnnotation> anno = [self.map.annotations objectAtIndex:((UIButton*) sender).tag];
	NSLog(@"Delete Annotation Button Clicked: %@", [anno title]);
	
	if ([anno title] == @"Custom User Location") {
		[MixareUtils setUserProvidedLocation:nil];
	}
	else {
		for (int x=0; x < [_data count]; x++) {
			NSDictionary *poiEntry = [_data objectAtIndex:x];
			if ([poiEntry valueForKey:@"title"] == [anno title]){
				[_data removeObjectAtIndex:x];
				break;
			}
		}
        [MixareUtils deleteImage:[anno title]];
	}	
    
	
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:@"PoiArray.plist"];
	[_data writeToFile:plistPath atomically:YES];
	
    
	[self mapDataToMapAnnotations];

}

- (void) dealloc {
	[super dealloc];
	[overlay release];
	[_map release];
	[_mapTileToggleButton release];
	[_data release];
	[_locmng release];
}

@end
