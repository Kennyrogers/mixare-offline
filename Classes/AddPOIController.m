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
@synthesize initialImage = _initialImage;

@synthesize labelName;
@synthesize labelLat;
@synthesize labelLon;

@synthesize textFieldName;	
@synthesize textFieldLat;	
@synthesize textFieldLon;	

@synthesize saveNewPOIButton;
@synthesize capture;
@synthesize choose;

@synthesize dataSourceArray = source; 



@synthesize imgPicker;
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
    [image setImage:_initialImage];
    
    self.imgPicker = [[UIImagePickerController alloc]init];
    self.imgPicker.allowsEditing = YES;
    self.imgPicker.delegate = self;
    
    
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
    [_initialImage release];
	
	[labelName release];
	[labelLat release];
	[labelLon release];
	
	[textFieldName release];
	[textFieldLat release];
	[textFieldLon release];
	
	[saveNewPOIButton release];
    [capture release];
    [choose release];
    
	[source release];
    [super dealloc];
}

- (IBAction)doneButtonOnKeyBoardPressed: (id)sender
{
    
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
    

    
    
    
    //saving image to photo library
//    UIImageWriteToSavedPhotosAlbum(image.image, self, nil, nil);
    
    
    //saving image to app's sandbox
    [self saveImage:image.image:textFieldName.text];

	[self.navigationController popToRootViewControllerAnimated:YES];
}




- (IBAction)grabImage:(UIButton *)sender{
//    UIButton *senderButt = (UIButton *)sender;

    
    if(sender.tag == 1)
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if(sender.tag == 2)
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        


	[self presentModalViewController:self.imgPicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	image.image = img;	
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

//saving an image

- (void)saveImage:(UIImage*)img:(NSString*)imgName {
    
    NSData *imageData = UIImagePNGRepresentation(img); //convert image into .png format.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imgName]]; //add our image to the path
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    
    NSLog(@"image saved");
    
}

// loading an image
- (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}



@end
