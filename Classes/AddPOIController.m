//
//  AddPOIController.m
//  Mixare
//
//  Created by David Ho on 9/18/11.
//  Copyright 2011 Peer GmbH. All rights reserved.
//

#import "AddPOIController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MixareUtils.h"

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
@synthesize imgInfo;


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
	[imgInfo release];
    
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
    
    
    if(!image.image)
    {
        UIAlertView *alert;
         alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"No image attached to POI" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
    
    
        //saving image to photo library
        //    UIImageWriteToSavedPhotosAlbum(image.image, self, nil, nil);
        //getting the assets library
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock = ^(NSURL *newURL, NSError *error){
            UIAlertView *alert;
            
            if(error)
                alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"Error saving image with metadata to Photo Library" delegate:self cancelButtonTitle:@"return" otherButtonTitles:nil];
            else
                alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"Image with EXIF data saved to Photo Album" delegate:self cancelButtonTitle:@"return" otherButtonTitles:nil];
            
            [alert show];
            [alert release];
        };
        
        
        [library writeImageToSavedPhotosAlbum:[image.image CGImage] metadata:[MixareUtils updateMetadata:imgInfo :[NSString stringWithFormat:@"Target: [latitude = %@ longitude = %@]", textFieldLat.text, textFieldLon.text]] completionBlock:imageWriteCompletionBlock];
        
        //saving image to app's sandbox
        
        [MixareUtils saveImage:image.image :textFieldName.text];
    }
	[self.navigationController popToRootViewControllerAnimated:YES];
}




- (IBAction)grabImage:(UIButton *)sender{
    //    UIButton *senderButt = (UIButton *)sender;
    
    self.imgPicker = [[UIImagePickerController alloc]init];
    self.imgPicker.allowsEditing = NO;
    self.imgPicker.delegate = self;
    
    if(sender.tag == 1)
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if(sender.tag == 2)
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    
	[self presentModalViewController:self.imgPicker animated:YES];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
//    imgInfo = editInfo;
//	image.image = img;	
//	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage; /*, *editedImage, *imageToSave;*/
    
    //handle a still image capture
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0)==kCFCompareEqualTo)
    {

        originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
         
        //getting the image metadata only if picker source is camera
        UIImagePickerControllerSourceType pickerType = picker.sourceType;
        if(pickerType == UIImagePickerControllerSourceTypeCamera)   //if its source is camera
        {
            NSDictionary *imageMetadata = [info objectForKey: UIImagePickerControllerMediaMetadata];
                        
            //saving imageMetadata for editing later.
            imgInfo = [[NSMutableDictionary alloc]initWithCapacity:[imageMetadata count]];
            NSEnumerator *enumerator = [imageMetadata keyEnumerator];
            id key;
            while((key = [enumerator nextObject]))
            {
                NSLog(@"%@",key);
                [imgInfo setObject:[imageMetadata valueForKey:key] forKey:(NSString *)key];
            }
        }
        else if(pickerType == UIImagePickerControllerSourceTypePhotoLibrary)    //if source is photo library
        {
            NSURL *assetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            NSLog(@"%@",assetUrl);
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library assetForURL:assetUrl resultBlock:^(ALAsset *asset)
             {
                 ALAssetRepresentation *representation = [asset defaultRepresentation];
                 NSMutableDictionary *imageMetadata = (NSMutableDictionary*)[representation metadata];
                 NSEnumerator *enumerator = [imageMetadata keyEnumerator];
                 id key;
                 while((key = [enumerator nextObject])) // can only be done inside the block.
                 {
                     NSLog(@"%@",key);
                     [imgInfo setObject:[imageMetadata valueForKey:key] forKey:(NSString *)key];
                 }
             }failureBlock:^(NSError *error) {
                 NSLog(@"%@",[error description]);
             }];
                              
           
        }
    }
    image.image = originalImage;
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [picker release];
}




@end
