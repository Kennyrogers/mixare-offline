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
@synthesize subTitle= _subTitle, title= _title, source=_source;


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
@synthesize focusArea = _focusArea;
@synthesize data = _data;
@synthesize overlay;
@synthesize longPressedCoords = _longPressedCoords;

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    _map.delegate= self;
	MKCoordinateRegion newRegion;
	CLLocationCoordinate2D userLocation = [MixareUtils GetUserPosition];
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
	if (_focusArea.center.latitude != 0.0 && _focusArea.center.longitude != 0.0) {
		[self.map setRegion:_focusArea animated:YES];
	}
	
	_focusArea.center.latitude = 0.0;
	_focusArea.center.longitude = 0.0;
	_focusArea.span.latitudeDelta = 0.0;
	_focusArea.span.longitudeDelta = 0.0;
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
		MixareUtils.userProvidedLocation = _longPressedCoords;
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
		NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:[self.map.annotations count] ];
		for (id annotation in self.map.annotations)
		{
			if (annotation != self.map.userLocation)
			{
				[toRemove addObject:annotation];
			}
		}
		[self.map removeAnnotations:toRemove];

		MapAnnotation * tmpPlace; 
		for(NSDictionary * poi in _data){
			tmpPlace = [[MapAnnotation alloc]init];
			tmpPlace.title = [poi valueForKey:@"title"];
			tmpPlace.lat = [[poi valueForKey:@"lat"]floatValue];
			tmpPlace.lon = [[poi valueForKey:@"lon"]floatValue];
            tmpPlace.source = [poi valueForKey:@"source"];
            
            [self.map addAnnotation:tmpPlace];
			[tmpPlace release];
		}
		
		if ([MixareUtils isCustomUserLocSet]) {
			tmpPlace = [[MapAnnotation alloc]init];
			tmpPlace.title = @"Custom User Location";
			tmpPlace.lat = [MixareUtils GetUserPosition].latitude;
			tmpPlace.lon = [MixareUtils GetUserPosition].longitude;
			tmpPlace.source = @"";
			
			[self.map addAnnotation:tmpPlace];
			[tmpPlace release];
		}
	}
}

- (IBAction) ToggleMapTiles:(id)sender
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// getting an NSString
	NSString *tilePreference = [prefs stringForKey:@"mapTilesToDisplay"];
	
	if (tilePreference == @"TILES_SAT") {
		[prefs setObject:@"TILES_TOPO" forKey:@"mapTilesToDisplay"];
	}
	else {
		[prefs setObject:@"TILES_SAT" forKey:@"mapTilesToDisplay"];
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
		[MixareUtils setUserProvidedLocation:CLLocationCoordinate2DMake(0,0)];
	}
	else {
		for (int x=0; x < [_data count]; x++) {
			NSDictionary *poiEntry = [_data objectAtIndex:x];
			if ([poiEntry valueForKey:@"title"] == [anno title]){
				[_data removeObjectAtIndex:x];
				break;
			}
		}
	}	

	
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:@"PoiArray.plist"];
	[_data writeToFile:plistPath atomically:YES];
	
	[self mapDataToMapAnnotations];
}

- (void) dealloc {
	[super dealloc];
	[overlay release];
}

@end
