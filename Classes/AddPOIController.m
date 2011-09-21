//
//  AddPOIController.m
//  Mixare
//
//  Created by David Ho on 9/18/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import "AddPOIController.h"


@implementation AddPOIController

@synthesize initialName = _initialName;
@synthesize initialLat = _initialLat;
@synthesize initialLon = _initialLon;

@synthesize labelName;
@synthesize labelLat;
@synthesize labelLon;

@synthesize textFieldName;	
@synthesize textFieldLat;	
@synthesize textFieldLon;	

@synthesize saveNewPOIButton;

@synthesize dataSourceArray = source; 

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Add New POI", nil);
	[textFieldName setText:_initialName];
	[textFieldLat setText:_initialLat];
	[textFieldLon setText:_initialLon];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[_initialName release];
	[_initialLat release];
	[_initialLon release];	
	
	[labelName release];
	[labelLat release];
	[labelLon release];
	
	[textFieldName release];
	[textFieldLat release];
	[textFieldLon release];
	
	[saveNewPOIButton release];
	
	[source release];
    [super dealloc];
}

- (IBAction) SaveNewPOI
{
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:@"PoiArray.plist"];

	NSLog(@"Name : %@", textFieldName.text);
	NSLog(@"Lat : %@", textFieldLat.text);
	NSLog(@"Lon : %@", textFieldLon.text);
	
	[source addObject:[NSDictionary dictionaryWithObjectsAndKeys: textFieldName.text, @"title", textFieldLat.text, @"lat",textFieldLon.text, @"lon", nil]];

	NSLog(@"POIs saved to: %@", plistPath);
	
	[source writeToFile:plistPath atomically:YES];

	//[poiArray release];

	[self.navigationController popToRootViewControllerAnimated:YES];
}


@end
